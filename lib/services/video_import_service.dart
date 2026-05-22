import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/video_repository.dart';
import 'bilibili_service.dart';

final videoImportServiceProvider = Provider<VideoImportService>((ref) {
  return VideoImportService(ref.watch(videoRepositoryProvider));
});

enum ImportStep { extracting, downloading, subtitling, importing, done, error }

class ImportState {
  final ImportStep step;
  final String message;
  final double? progress;

  const ImportState(this.step, this.message, [this.progress]);
}

class VideoMeta {
  final String title;
  final double? duration;

  const VideoMeta({required this.title, this.duration});
}

class VideoImportService {
  final VideoRepository _repo;
  static const _uuid = Uuid();

  VideoImportService(this._repo);

  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  String? extractUrl(String text) {
    final match = RegExp(r'https?://\S+').firstMatch(text);
    return match?.group(0);
  }

  Future<String> resolveUrl(String url) async {
    final shortDomains = ['b23.tv', 'm.toutiao.com/is'];
    final isShort = shortDomains.any((d) => url.contains(d));
    if (!isShort) return url;

    try {
      final request = http.Request('GET', Uri.parse(url))
        ..followRedirects = false;
      final client = http.Client();
      final response = await client.send(request);
      client.close();
      final location = response.headers['location'];
      if (location != null && location.startsWith('http')) {
        return location;
      }
    } catch (e) {
      debugPrint('[Import] resolveUrl error: $e');
    }
    return url;
  }

  Future<VideoMeta?> fetchVideoInfo(String url) async {
    try {
      final result = await Process.run('yt-dlp', ['--dump-json', '--no-download', url],
          stdoutEncoding: utf8, stderrEncoding: utf8);
      if (result.exitCode != 0) {
        debugPrint('[Import] yt-dlp info error: ${result.stderr}');
        return null;
      }
      final data = jsonDecode(result.stdout as String) as Map<String, dynamic>;
      return VideoMeta(
        title: data['title'] as String? ?? 'Untitled',
        duration: (data['duration'] as num?)?.toDouble(),
      );
    } catch (e) {
      debugPrint('[Import] fetchVideoInfo error: $e');
      return null;
    }
  }

  Future<String?> downloadVideo(String url, String id) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final videoDir = Directory(p.join(dir.path, 'videos'));
      await videoDir.create(recursive: true);
      final outputPath = p.join(videoDir.path, '$id.mp4');

      final result = await Process.run(
        'yt-dlp',
        ['-f', 'best[height<=720]/best', '-o', outputPath, '--no-part', url],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      if (result.exitCode != 0) {
        debugPrint('[Import] yt-dlp download error: ${result.stderr}');
        return null;
      }

      if (await File(outputPath).exists()) return outputPath;

      final downloaded = await videoDir
          .list()
          .where((f) => p.basenameWithoutExtension(f.path) == id)
          .first;
      return downloaded.path;
    } catch (e) {
      debugPrint('[Import] downloadVideo error: $e');
      return null;
    }
  }

  Future<String?> generateSubtitles(String videoPath, String id) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final subtitleDir = Directory(p.join(dir.path, 'subtitles'));
      await subtitleDir.create(recursive: true);

      final result = await Process.run(
        'whisper',
        [
          videoPath,
          '--model', 'base',
          '--language', 'en',
          '--output_format', 'srt',
          '--output_dir', subtitleDir.path,
        ],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      if (result.exitCode != 0) {
        debugPrint('[Import] whisper error: ${result.stderr}');
        return null;
      }

      final baseName = p.basenameWithoutExtension(videoPath);
      final srtPath = p.join(subtitleDir.path, '$baseName.srt');
      if (await File(srtPath).exists()) {
        final destPath = p.join(subtitleDir.path, '$id.srt');
        if (srtPath != destPath) {
          await File(srtPath).rename(destPath);
        }
        return destPath;
      }
      return null;
    } catch (e) {
      debugPrint('[Import] generateSubtitles error: $e');
      return null;
    }
  }

  Future<void> importFromText(
    String text,
    ValueNotifier<ImportState> state, {
    Future<BilibiliPage?> Function(List<BilibiliPage> pages)? onSelectPage,
  }) async {
    final rawUrl = extractUrl(text);
    if (rawUrl == null) {
      state.value = const ImportState(ImportStep.error, '未找到有效链接');
      return;
    }

    // Step 1: Resolve short link
    state.value = const ImportState(ImportStep.extracting, '解析链接...');
    final url = await resolveUrl(rawUrl);
    debugPrint('[Import] resolved URL: $url');

    // Check if it's a Bilibili URL
    if (BilibiliService.isBilibiliUrl(url)) {
      await _importFromBilibili(url, state, onSelectPage: onSelectPage);
      return;
    }

    final id = _uuid.v4();

    // Non-Bilibili: use yt-dlp
    final meta = await fetchVideoInfo(url);
    if (meta == null) {
      state.value = const ImportState(ImportStep.error, '无法解析视频信息，请检查链接');
      return;
    }

    // Step 2: Download video
    state.value = ImportState(ImportStep.downloading, '下载视频: ${meta.title}');
    final videoPath = await downloadVideo(url, id);
    if (videoPath == null) {
      state.value = const ImportState(ImportStep.error, '视频下载失败');
      return;
    }

    // Step 3: Generate subtitles
    state.value = const ImportState(ImportStep.subtitling, '生成字幕中 (可能需要几分钟)...');
    final subtitlePath = await generateSubtitles(videoPath, id);

    // Step 4: Import into app
    state.value = const ImportState(ImportStep.importing, '导入中...');
    await _repo.importVideoFromFile(
      id: id,
      title: meta.title,
      filePath: videoPath,
      subtitlePath: subtitlePath,
      sourceUrl: url,
    );

    state.value = const ImportState(ImportStep.done, '导入完成');
  }

  Future<void> _importFromBilibili(
    String url,
    ValueNotifier<ImportState> state, {
    Future<BilibiliPage?> Function(List<BilibiliPage> pages)? onSelectPage,
  }) async {
    try {
      // Resolve b23.tv short links
      final resolvedUrl = await BilibiliService.resolveShortUrl(url);
      final bvid = BilibiliService.extractBvid(resolvedUrl);
      if (bvid == null) {
        state.value = const ImportState(ImportStep.error, '无法提取B站视频ID');
        return;
      }

      debugPrint('[Import] Bilibili BVID: $bvid');

      // Fetch video info
      final info = await BilibiliService.fetchVideoInfo(bvid);
      if (info == null) {
        state.value = const ImportState(ImportStep.error, '无法获取B站视频信息');
        return;
      }

      debugPrint('[Import] Bilibili title: ${info.title}, pages: ${info.pages.length}');

      // Handle multi-page videos
      BilibiliPage selectedPage;
      if (info.pages.length > 1 && onSelectPage != null) {
        state.value = ImportState(
          ImportStep.extracting,
          '${info.title} (共${info.pages.length}集，请选择)',
        );
        final picked = await onSelectPage(info.pages);
        if (picked == null) {
          state.value = const ImportState(ImportStep.error, '已取消');
          return;
        }
        selectedPage = picked;
      } else {
        selectedPage = info.pages.first;
      }

      final id = _uuid.v4();
      final title = info.pages.length > 1
          ? '${info.title} - P${selectedPage.page} ${selectedPage.partName}'
          : info.title;

      // Get stream URL
      state.value = ImportState(ImportStep.downloading, '获取视频流: $title');
      final streamUrl =
          await BilibiliService.getStreamUrl(info.aid, selectedPage.cid);
      if (streamUrl == null) {
        state.value = const ImportState(ImportStep.error, '无法获取视频流地址');
        return;
      }

      // Download
      state.value = ImportState(ImportStep.downloading, '下载视频: $title');
      final dir = await getApplicationDocumentsDirectory();
      final videoDir = Directory(p.join(dir.path, 'videos'));
      await videoDir.create(recursive: true);
      final tempPath = p.join(videoDir.path, '$id.flv');
      final mp4Path = p.join(videoDir.path, '$id.mp4');

      final downloadedPath =
          await BilibiliService.downloadStream(streamUrl, tempPath);
      if (downloadedPath == null) {
        state.value = const ImportState(ImportStep.error, '视频下载失败');
        return;
      }

      // Convert FLV to MP4
      state.value = ImportState(ImportStep.downloading, '转换格式: $title');
      final videoPath = await BilibiliService.convertToMp4(tempPath, mp4Path);
      if (videoPath == null) {
        state.value = const ImportState(ImportStep.error, '视频格式转换失败');
        return;
      }

      // Generate subtitles
      state.value =
          const ImportState(ImportStep.subtitling, '生成字幕中 (可能需要几分钟)...');
      final subtitlePath = await generateSubtitles(videoPath, id);

      // Import
      state.value = const ImportState(ImportStep.importing, '导入中...');
      await _repo.importVideoFromFile(
        id: id,
        title: title,
        filePath: videoPath,
        subtitlePath: subtitlePath,
        sourceUrl:
            'https://www.bilibili.com/video/$bvid/?p=${selectedPage.page}',
      );

      state.value = const ImportState(ImportStep.done, '导入完成');
    } catch (e) {
      debugPrint('[Import] Bilibili import error: $e');
      state.value = ImportState(ImportStep.error, 'B站导入异常: $e');
    }
  }
}
