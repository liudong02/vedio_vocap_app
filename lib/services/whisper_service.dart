import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

final whisperServiceProvider = Provider<WhisperService>((ref) {
  return WhisperService();
});

class WhisperService {
  static const _modelName = 'ggml-tiny.bin';
  static const _downloadUrl =
      'https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main/$_modelName';
  static const _audioChannel = MethodChannel('video_vocab/audio');

  Future<String> get _modelDir async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, 'whisper_models');
  }

  Future<String> get _modelPath async {
    return p.join(await _modelDir, _modelName);
  }

  Future<bool> isModelDownloaded() async {
    final path = await _modelPath;
    return File(path).existsSync();
  }

  Future<void> downloadModel({
    required void Function(double progress) onProgress,
  }) async {
    final dir = Directory(await _modelDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final modelPath = await _modelPath;
    final tempPath = '$modelPath.tmp';

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(_downloadUrl));
      request.headers.set('User-Agent', 'VideoVocab/1.0');
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('下载失败: HTTP ${response.statusCode}');
      }

      final totalBytes = response.contentLength;
      var receivedBytes = 0;
      final file = File(tempPath);
      final sink = file.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.close();
      await File(tempPath).rename(modelPath);
    } finally {
      client.close();
    }
  }

  Future<String?> transcribe(
    String videoPath,
    String subtitleId, {
    void Function(String message, double? progress)? onStatus,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final subtitleDir = Directory(p.join(dir.path, 'subtitles'));
      await subtitleDir.create(recursive: true);

      final wavPath = p.join(subtitleDir.path, '$subtitleId.wav');

      // Step 1: Extract audio — no intermediate progress available
      onStatus?.call('提取音频中...', null);
      debugPrint('[Whisper] Converting to WAV: $videoPath -> $wavPath');
      try {
        await _audioChannel.invokeMethod('extractWav', {
          'input': videoPath,
          'output': wavPath,
          'sampleRate': 16000,
        });
      } catch (e) {
        debugPrint('[Whisper] WAV conversion failed: $e');
        return null;
      }

      if (!await File(wavPath).exists()) {
        debugPrint('[Whisper] WAV file not created');
        return null;
      }
      final wavSize = await File(wavPath).length();
      debugPrint('[Whisper] WAV file size: ${wavSize ~/ 1024}KB');

      // Step 2: Whisper transcription — no intermediate progress available
      onStatus?.call('识别语音中...', null);
      debugPrint('[Whisper] Starting transcription...');
      final modelDir = await _modelDir;
      final whisper = Whisper(
        model: WhisperModel.tiny,
        modelDir: modelDir,
      );

      final WhisperTranscribeResponse result;
      try {
        result = await whisper.transcribe(
          transcribeRequest: TranscribeRequest(
            audio: wavPath,
            language: 'en',
            isNoTimestamps: false,
            isTranslate: false,
            splitOnWord: false,
            threads: 2,
          ),
        );
      } catch (e) {
        debugPrint('[Whisper] Transcription failed: $e');
        await File(wavPath).delete().catchError((_) => File(''));
        return null;
      }
      debugPrint('[Whisper] Transcription complete, segments: ${result.segments?.length}');

      onStatus?.call('生成字幕文件...', 0.95);

      // Convert segments to SRT
      final srtPath = p.join(subtitleDir.path, '$subtitleId.srt');
      final segments = result.segments;
      if (segments == null || segments.isEmpty) {
        debugPrint('[Whisper] No segments returned');
        await File(wavPath).delete().catchError((_) => File(''));
        return null;
      }

      final srt = _segmentsToSrt(segments);
      await File(srtPath).writeAsString(srt);

      await File(wavPath).delete().catchError((_) => File(''));

      onStatus?.call('字幕生成完成', 1.0);
      return srtPath;
    } catch (e) {
      debugPrint('[Whisper] transcribe error: $e');
      return null;
    }
  }

  String _segmentsToSrt(List<WhisperTranscribeSegment> segments) {
    final buffer = StringBuffer();
    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      buffer.writeln(i + 1);
      buffer.writeln('${_formatSrtTime(seg.fromTs)} --> ${_formatSrtTime(seg.toTs)}');
      buffer.writeln(seg.text.trim());
      buffer.writeln();
    }
    return buffer.toString();
  }

  String _formatSrtTime(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$millis';
  }
}
