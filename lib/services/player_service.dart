import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../data/models/subtitle_cue.dart';
import '../core/utils/srt_parser.dart';

final playerProvider = Provider<Player>((ref) {
  final player = Player();
  ref.onDispose(player.dispose);
  return player;
});

final activeCueProvider = StateProvider<SubtitleCue?>((ref) => null);

final subtitleCuesProvider = StateProvider<List<SubtitleCue>>((ref) => []);

class PlayerStateData {
  final bool isLoading;
  final String? videoPath;
  final String? error;

  const PlayerStateData({
    this.isLoading = false,
    this.videoPath,
    this.error,
  });

  PlayerStateData copyWith({bool? isLoading, String? videoPath, String? error}) =>
      PlayerStateData(
        isLoading: isLoading ?? this.isLoading,
        videoPath: videoPath ?? this.videoPath,
        error: error ?? this.error,
      );
}

class PlayerNotifier extends StateNotifier<PlayerStateData> {
  final Ref _ref;
  StreamSubscription<Duration>? _positionSub;
  List<SubtitleCue> _cues = [];
  int _offsetMs = 0;
  Duration _lastPosition = Duration.zero;

  PlayerNotifier(this._ref) : super(const PlayerStateData());

  Player get player => _ref.read(playerProvider);

  Future<void> loadVideo({
    required String videoPath,
    String? subtitlePath,
    int subtitleOffsetMs = 0,
  }) async {
    state = state.copyWith(isLoading: true);
    _offsetMs = subtitleOffsetMs;
    _ref.read(activeCueProvider.notifier).state = null;

    if (subtitlePath != null && await File(subtitlePath).exists()) {
      try {
        final content = await File(subtitlePath).readAsString();
        _cues = SrtParser.parse(content);
        _ref.read(subtitleCuesProvider.notifier).state = _cues;
        debugPrint('[Player] Loaded ${_cues.length} subtitle cues from $subtitlePath');
        if (_cues.isNotEmpty) {
          debugPrint('[Player] First cue: ${_cues.first.start} - ${_cues.first.end}: ${_cues.first.text}');
        }
      } catch (e) {
        debugPrint('[Player] Error loading subtitles: $e');
        _cues = [];
        _ref.read(subtitleCuesProvider.notifier).state = [];
      }
    } else {
      debugPrint('[Player] No subtitle file: $subtitlePath');
      _cues = [];
      _ref.read(subtitleCuesProvider.notifier).state = [];
    }

    _startSync();
    await player.open(Media('file://$videoPath'));
    state = state.copyWith(isLoading: false, videoPath: videoPath);
  }

  void _startSync() {
    _positionSub?.cancel();
    _positionSub = player.stream.position.listen((pos) {
      if (pos == _lastPosition) return;
      _lastPosition = pos;
      final adjusted = Duration(
        milliseconds: pos.inMilliseconds + _offsetMs,
      );
      final cue = _findActiveCue(adjusted);
      _ref.read(activeCueProvider.notifier).state = cue;
    });
  }

  SubtitleCue? _findActiveCue(Duration position) {
    if (_cues.isEmpty) return null;
    int lo = 0, hi = _cues.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final cue = _cues[mid];
      if (cue.end < position) {
        lo = mid + 1;
      } else if (cue.start > position) {
        hi = mid - 1;
      } else {
        return cue;
      }
    }
    return null;
  }

  void togglePlayPause() {
    if (player.state.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void pause() => player.pause();
  void play() => player.play();
  void seek(Duration pos) => player.seek(pos);

  void setSubtitleOffset(int ms) {
    _offsetMs = ms;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerStateData>((ref) {
  return PlayerNotifier(ref);
});
