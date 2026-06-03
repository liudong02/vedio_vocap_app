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
import 'toutiao_service.dart';
import 'whisper_service.dart';

final videoImportServiceProvider = Provider<VideoImportService>((ref) {
  return VideoImportService(
    ref.watch(videoRepositoryProvider),
    ref.watch(whisperServiceProvider),
  );
});

enum ImportStep { extracting, modelDownloading, downloading, subtitling, importing, done, doneWithoutSubtitle, error }

class ImportState {
  final ImportStep step;
  final String message;
  final double? progress;
  final bool needsModelDownload;
  final String? videoId;

  const ImportState(this.step, this.message, [this.progress, this.needsModelDownload = false, this.videoId]);
}

class VideoMeta {
  final String title;
  final double? duration;

  const VideoMeta({required this.title, this.duration});
}

class VideoImportService {
  final VideoRepository _repo;
  final WhisperService _whisper;
  static const _uuid = Uuid();

  VideoImportService(this._repo, this._whisper);

  static bool get _isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  String? extractUrl(String text) {
    final match = RegExp(r'https?://\S+').firstMatch(text);
    return match?.group(0);
  }

  Future<String> resolveUrl(String url) async {
    final shortDomains = ['b23.tv', 'm.toutiao.com/is', 'v.douyin.com'];
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

  Future<String?> downloadVideo(String url, String id, {
    void Function(double)? onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final videoDir = Directory(p.join(dir.path, 'videos'));
      await videoDir.create(recursive: true);
      final outputPath = p.join(videoDir.path, '$id.mp4');

      final process = await Process.start(
        'yt-dlp',
        ['-f', 'best[height<=720]/best', '-o', outputPath, '--no-part', '--newline', url],
      );

      final percentRegex = RegExp(r'(\d+\.?\d*)%');
      process.stdout.transform(utf8.decoder).listen((data) {
        final match = percentRegex.firstMatch(data);
        if (match != null) {
          onProgress?.call(double.parse(match.group(1)!) / 100);
        }
      });
      process.stderr.transform(utf8.decoder).listen((data) {
        debugPrint('[Import] yt-dlp stderr: $data');
      });

      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        debugPrint('[Import] yt-dlp download exit code: $exitCode');
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

  Future<String?> generateSubtitles(String videoPath, String id, {
    void Function(String message, double? progress)? onStatus,
    void Function(double)? onProgress,
    double? videoDurationSec,
  }) async {
    if (_isMobile) {
      return _whisper.transcribe(videoPath, id, onStatus: onStatus);
    }
    return _generateSubtitlesDesktop(videoPath, id,
        onProgress: onProgress, videoDurationSec: videoDurationSec);
  }

  Future<String?> _generateSubtitlesDesktop(String videoPath, String id, {
    void Function(double)? onProgress,
    double? videoDurationSec,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final subtitleDir = Directory(p.join(dir.path, 'subtitles'));
      await subtitleDir.create(recursive: true);

      final process = await Process.start(
        'whisper',
        [
          videoPath,
          '--model', 'base',
          '--language', 'en',
          '--output_format', 'srt',
          '--output_dir', subtitleDir.path,
          '--verbose', 'True',
        ],
        environment: {'PYTHONUNBUFFERED': '1'},
      );

      final tsRegex = RegExp(r'-->\s*(\d+):(\d+)\.(\d+)\]');
      process.stdout.transform(utf8.decoder).listen((data) {
        if (videoDurationSec != null && videoDurationSec > 0 && onProgress != null) {
          final match = tsRegex.firstMatch(data);
          if (match != null) {
            final mins = int.parse(match.group(1)!);
            final secs = int.parse(match.group(2)!);
            final endSec = mins * 60 + secs;
            final p = (endSec / videoDurationSec).clamp(0.0, 1.0);
            onProgress(p);
          }
        }
      });
      process.stderr.transform(utf8.decoder).listen((_) {});

      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        debugPrint('[Import] whisper exit code: $exitCode');
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

    // Check model status for mobile (needed for subtitle generation)
    bool needsModelDownload = false;
    if (_isMobile) {
      needsModelDownload = !(await _whisper.isModelDownloaded());
    }

    // Check if it's a Bilibili URL
    if (BilibiliService.isBilibiliUrl(url)) {
      await _importFromBilibili(url, state,
          onSelectPage: onSelectPage, needsModelDownload: needsModelDownload);
      return;
    }

    // Check if it's a Toutiao/Douyin URL
    if (ToutiaoService.isToutiaoUrl(url)) {
      await _importFromToutiao(url, state, needsModelDownload: needsModelDownload);
      return;
    }

    // Non-platform URLs: desktop only (requires yt-dlp)
    if (_isMobile) {
      state.value = const ImportState(ImportStep.error, '暂不支持该平台链接，请使用B站或头条链接');
      return;
    }

    final id = _uuid.v4();

    final meta = await fetchVideoInfo(url);
    if (meta == null) {
      state.value = const ImportState(ImportStep.error, '无法解析视频信息，请检查链接');
      return;
    }

    // Download model if needed
    if (needsModelDownload) {
      await _downloadModelStep(state);
    }

    // Step 2: Download video
    state.value = ImportState(ImportStep.downloading, '下载视频: ${meta.title}');
    final videoPath = await downloadVideo(url, id, onProgress: (p) {
      state.value = ImportState(
        ImportStep.downloading, '下载视频: ${(p * 100).toInt()}%', p,
      );
    });
    if (videoPath == null) {
      state.value = const ImportState(ImportStep.error, '视频下载失败');
      return;
    }

    // Step 3: Generate subtitles
    state.value = const ImportState(ImportStep.subtitling, '生成字幕中...');
    final subtitlePath = await generateSubtitles(videoPath, id,
      videoDurationSec: meta.duration,
      onStatus: (message, progress) {
        state.value = ImportState(ImportStep.subtitling, message, progress);
      },
      onProgress: (p) {
        state.value = ImportState(
          ImportStep.subtitling, '生成字幕: ${(p * 100).toInt()}%', p,
        );
      },
    );

    // Step 4: Import into app
    state.value = const ImportState(ImportStep.importing, '导入中...');
    await _repo.importVideoFromFile(
      id: id,
      title: meta.title,
      filePath: videoPath,
      subtitlePath: subtitlePath,
      sourceUrl: url,
    );

    if (subtitlePath != null) {
      state.value = ImportState(ImportStep.done, '导入完成', null, false, id);
    } else {
      state.value = ImportState(ImportStep.doneWithoutSubtitle, '视频已导入，字幕生成失败', null, false, id);
    }
  }

  Future<void> _downloadModelStep(ValueNotifier<ImportState> state) async {
    state.value = const ImportState(ImportStep.modelDownloading, '首次使用，下载字幕模型...', 0.0, true);
    try {
      await _whisper.downloadModel(onProgress: (p) {
        state.value = ImportState(
          ImportStep.modelDownloading, '下载字幕模型: ${(p * 100).toInt()}%', p, true,
        );
      });
    } catch (e) {
      state.value = ImportState(ImportStep.error, '模型下载失败: $e');
      rethrow;
    }
  }

  Future<void> _importFromToutiao(
    String url,
    ValueNotifier<ImportState> state, {
    bool needsModelDownload = false,
  }) async {
    try {
      state.value = const ImportState(ImportStep.extracting, '解析头条视频...');

      final info = await ToutiaoService.fetchVideoInfo(url);
      if (info == null) {
        state.value = const ImportState(ImportStep.error, '无法解析头条视频，请检查链接');
        return;
      }

      final id = _uuid.v4();

      // Download model if needed
      if (needsModelDownload) {
        await _downloadModelStep(state);
      }

      // Download video
      state.value = ImportState(ImportStep.downloading, '下载视频: ${info.title}');
      final dir = await getApplicationDocumentsDirectory();
      final videoDir = Directory(p.join(dir.path, 'videos'));
      await videoDir.create(recursive: true);
      final outputPath = p.join(videoDir.path, '$id.mp4');

      final videoPath = await ToutiaoService.downloadVideo(
        info.videoUrl,
        outputPath,
        onProgress: (p) {
          state.value = ImportState(
            ImportStep.downloading, '下载视频: ${(p * 100).toInt()}%', p,
          );
        },
      );
      if (videoPath == null) {
        state.value = const ImportState(ImportStep.error, '视频下载失败');
        return;
      }

      // Generate subtitles
      state.value = const ImportState(ImportStep.subtitling, '生成字幕中...');
      final subtitlePath = await generateSubtitles(videoPath, id,
        videoDurationSec: info.duration,
        onStatus: (message, progress) {
          state.value = ImportState(ImportStep.subtitling, message, progress);
        },
        onProgress: (p) {
          state.value = ImportState(
            ImportStep.subtitling, '生成字幕: ${(p * 100).toInt()}%', p,
          );
        },
      );

      // Import
      state.value = const ImportState(ImportStep.importing, '导入中...');
      await _repo.importVideoFromFile(
        id: id,
        title: info.title,
        filePath: videoPath,
        subtitlePath: subtitlePath,
        sourceUrl: url,
      );

      if (subtitlePath != null) {
        state.value = ImportState(ImportStep.done, '导入完成', null, false, id);
      } else {
        state.value = ImportState(ImportStep.doneWithoutSubtitle, '视频已导入，字幕生成失败', null, false, id);
      }
    } catch (e) {
      debugPrint('[Import] Toutiao import error: $e');
      if (e is! Exception || !state.value.message.contains('模型下载')) {
        state.value = ImportState(ImportStep.error, '头条导入异常: $e');
      }
    }
  }

  Future<void> _importFromBilibili(
    String url,
    ValueNotifier<ImportState> state, {
    Future<BilibiliPage?> Function(List<BilibiliPage> pages)? onSelectPage,
    bool needsModelDownload = false,
  }) async {
    try {
      final resolvedUrl = await BilibiliService.resolveShortUrl(url);
      final bvid = BilibiliService.extractBvid(resolvedUrl);
      if (bvid == null) {
        state.value = const ImportState(ImportStep.error, '无法提取B站视频ID');
        return;
      }

      debugPrint('[Import] Bilibili BVID: $bvid');

      final info = await BilibiliService.fetchVideoInfo(bvid);
      if (info == null) {
        state.value = const ImportState(ImportStep.error, '无法获取B站视频信息');
        return;
      }

      debugPrint('[Import] Bilibili title: ${info.title}, pages: ${info.pages.length}');

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

      // Download model if needed
      if (needsModelDownload) {
        await _downloadModelStep(state);
      }

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

      final downloadedPath = await BilibiliService.downloadStream(
        streamUrl, tempPath,
        onProgress: (p) {
          state.value = ImportState(
            ImportStep.downloading, '下载视频: ${(p * 100).toInt()}%', p,
          );
        },
      );
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
      state.value = const ImportState(ImportStep.subtitling, '生成字幕中...');
      final subtitlePath = await generateSubtitles(videoPath, id,
        videoDurationSec: selectedPage.duration,
        onStatus: (message, progress) {
          state.value = ImportState(ImportStep.subtitling, message, progress);
        },
        onProgress: (p) {
          state.value = ImportState(
            ImportStep.subtitling, '生成字幕: ${(p * 100).toInt()}%', p,
          );
        },
      );

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

      if (subtitlePath != null) {
        state.value = ImportState(ImportStep.done, '导入完成', null, false, id);
      } else {
        state.value = ImportState(ImportStep.doneWithoutSubtitle, '视频已导入，字幕生成失败', null, false, id);
      }
    } catch (e) {
      debugPrint('[Import] Bilibili import error: $e');
      if (e is! Exception || !state.value.message.contains('模型下载')) {
        state.value = ImportState(ImportStep.error, 'B站导入异常: $e');
      }
    }
  }

  Future<String?> regenerateSubtitlesForVideo(
    String videoId, [
    ValueNotifier<ImportState>? state,
  ]) async {
    final video = await _repo.getVideo(videoId);
    if (video == null) return null;

    if (_isMobile && !(await _whisper.isModelDownloaded())) {
      state?.value = const ImportState(ImportStep.modelDownloading, '下载字幕模型...', 0.0, true);
      await _whisper.downloadModel(onProgress: (p) {
        state?.value = ImportState(
          ImportStep.modelDownloading, '下载字幕模型: ${(p * 100).toInt()}%', p, true,
        );
      });
    }

    state?.value = const ImportState(ImportStep.subtitling, '生成字幕中...');
    final subtitlePath = await generateSubtitles(
      video.filePath, videoId,
      onStatus: (message, progress) {
        state?.value = ImportState(ImportStep.subtitling, message, progress);
      },
      onProgress: (p) {
        state?.value = ImportState(
          ImportStep.subtitling, '生成字幕: ${(p * 100).toInt()}%', p,
        );
      },
    );

    if (subtitlePath != null) {
      await _repo.updateSubtitlePath(videoId, subtitlePath);
      state?.value = ImportState(ImportStep.done, '字幕生成完成', null, false, videoId);
    } else {
      state?.value = ImportState(ImportStep.doneWithoutSubtitle, '字幕生成失败', null, false, videoId);
    }
    return subtitlePath;
  }
}
