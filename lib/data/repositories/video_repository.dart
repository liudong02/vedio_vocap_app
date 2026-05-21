import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(ref.watch(databaseProvider));
});

class VideoRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  VideoRepository(this._db);

  Stream<List<VideoEntry>> watchAll() => _db.watchAllVideos();

  Future<VideoEntry?> getVideo(String id) => _db.getVideo(id);

  Future<void> regenerateMissingThumbnails() async {
    final videos = await _db.getAllVideos();
    for (final video in videos) {
      if (video.thumbnailPath != null &&
          await File(video.thumbnailPath!).exists()) {
        continue;
      }
      final thumbPath = await _generateThumbnail(video.filePath, video.id);
      if (thumbPath != null) {
        await _db.updateVideo(
            video.id, VideosCompanion(thumbnailPath: Value(thumbPath)));
        debugPrint('[VideoRepo] regenerated thumbnail for ${video.title}');
      }
    }
  }

  Future<VideoEntry?> importVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final path = file.path;
    if (path == null) return null;

    debugPrint('[VideoRepo] picked file: $path');

    final id = _uuid.v4();
    final title = p.basenameWithoutExtension(path);

    String? thumbPath;
    try {
      thumbPath = await _generateThumbnail(path, id);
      debugPrint('[VideoRepo] thumbnail: $thumbPath');
    } catch (e) {
      debugPrint('[VideoRepo] thumbnail error: $e');
    }

    String? subtitlePath;
    try {
      subtitlePath = await _findMatchingSubtitle(path, id);
      debugPrint('[VideoRepo] subtitle: $subtitlePath');
    } catch (e) {
      debugPrint('[VideoRepo] subtitle search error: $e');
    }

    try {
      await _db.insertVideo(VideosCompanion.insert(
        id: id,
        title: title,
        filePath: path,
        thumbnailPath: Value(thumbPath),
        subtitlePath: Value(subtitlePath),
      ));
      debugPrint('[VideoRepo] inserted video id=$id');
    } catch (e) {
      debugPrint('[VideoRepo] DB insert error: $e');
      return null;
    }

    return _db.getVideo(id);
  }

  Future<String?> _findMatchingSubtitle(String videoPath, String videoId) async {
    final videoFile = File(videoPath);
    final dir = videoFile.parent.path;
    final baseName = p.basenameWithoutExtension(videoPath);

    for (final ext in ['srt', 'vtt']) {
      final candidate = File(p.join(dir, '$baseName.$ext'));
      if (await candidate.exists()) {
        final appDir = await getApplicationDocumentsDirectory();
        final subtitleDir = Directory(p.join(appDir.path, 'subtitles'));
        await subtitleDir.create(recursive: true);
        final destPath = p.join(subtitleDir.path, '$videoId.$ext');
        await candidate.copy(destPath);
        return destPath;
      }
    }
    return null;
  }

  Future<String?> importSubtitle(String videoId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final pickedPath = result.files.first.path;
    if (pickedPath == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final subtitleDir = Directory(p.join(dir.path, 'subtitles'));
    await subtitleDir.create(recursive: true);

    final ext = p.extension(pickedPath);
    final destPath = p.join(subtitleDir.path, '$videoId$ext');
    await File(pickedPath).copy(destPath);

    await _db.updateVideo(videoId, VideosCompanion(subtitlePath: Value(destPath)));

    return destPath;
  }

  Future<void> updateSubtitleOffset(String videoId, int offsetMs) async {
    await _db.updateVideo(videoId, VideosCompanion(subtitleOffsetMs: Value(offsetMs)));
  }

  Future<void> updateSubtitlePosition(String videoId, double positionY) async {
    await _db.updateVideo(videoId, VideosCompanion(subtitlePositionY: Value(positionY)));
  }

  Future<void> deleteVideo(String id) async {
    final video = await _db.getVideo(id);
    if (video?.thumbnailPath != null) {
      try {
        await File(video!.thumbnailPath!).delete();
      } catch (_) {}
    }
    await _db.deleteVideo(id);
  }

  Future<String?> _generateThumbnail(String videoPath, String id) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final thumbDir = Directory(p.join(dir.path, 'thumbnails'));
      await thumbDir.create(recursive: true);
      final outputPath = p.join(thumbDir.path, '$id.jpg');

      if (Platform.isMacOS || Platform.isLinux) {
        return _generateThumbnailWithFfmpeg(videoPath, outputPath);
      }

      final result = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 320,
        quality: 75,
      );
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _generateThumbnailWithFfmpeg(
      String videoPath, String outputPath) async {
    try {
      final result = await Process.run('ffmpeg', [
        '-i', videoPath,
        '-ss', '00:00:03',
        '-vframes', '1',
        '-vf', 'scale=480:-1',
        '-y',
        outputPath,
      ]);
      if (result.exitCode == 0 && await File(outputPath).exists()) {
        return outputPath;
      }
      debugPrint('[VideoRepo] ffmpeg stderr: ${result.stderr}');
      return null;
    } catch (e) {
      debugPrint('[VideoRepo] ffmpeg not available: $e');
      return null;
    }
  }
}
