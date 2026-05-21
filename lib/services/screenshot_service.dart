import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_thumbnail/video_thumbnail.dart';

final screenshotServiceProvider = Provider<ScreenshotService>((ref) {
  return ScreenshotService();
});

class ScreenshotService {
  Future<String?> captureAndSave({
    required String videoPath,
    required Duration position,
    required String wordId,
  }) async {
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: position.inMilliseconds,
        quality: 85,
      );
      if (bytes == null) return null;
      return _saveToFile(bytes, wordId);
    } catch (_) {
      return null;
    }
  }

  Future<String> _saveToFile(Uint8List bytes, String wordId) async {
    final dir = await getApplicationDocumentsDirectory();
    final screenshotsDir = Directory(p.join(dir.path, 'screenshots'));
    await screenshotsDir.create(recursive: true);
    final filePath = p.join(screenshotsDir.path, '$wordId.jpg');
    await File(filePath).writeAsBytes(bytes);
    return filePath;
  }
}
