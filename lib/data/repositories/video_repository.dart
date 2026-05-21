import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<VideoEntry?> importVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final path = file.path;
    if (path == null) return null;

    final id = _uuid.v4();
    final title = p.basenameWithoutExtension(path);
    final thumbPath = await _generateThumbnail(path, id);

    await _db.insertVideo(VideosCompanion.insert(
      id: id,
      title: title,
      filePath: path,
      thumbnailPath: Value(thumbPath),
    ));

    return _db.getVideo(id);
  }

  Future<String?> importSubtitle(String videoId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final path = result.files.first.path;
    if (path == null) return null;

    await _db.updateVideo(videoId, VideosCompanion(subtitlePath: Value(path)));

    return path;
  }

  Future<void> updateSubtitleOffset(String videoId, int offsetMs) async {
    await _db.updateVideo(videoId, VideosCompanion(subtitleOffsetMs: Value(offsetMs)));
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

      return VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 320,
        quality: 75,
      );
    } catch (_) {
      return null;
    }
  }
}
