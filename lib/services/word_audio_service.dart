import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

final wordAudioServiceProvider = Provider<WordAudioService>((ref) {
  final service = WordAudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

class WordAudioService {
  Player? _player;

  Future<void> play(String url) async {
    if (url.isEmpty) return;
    _player ??= Player();
    await _player!.open(Media(url), play: true);
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
