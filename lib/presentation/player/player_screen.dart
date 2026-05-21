import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../data/repositories/video_repository.dart';
import '../../services/player_service.dart';
import 'subtitle_overlay.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  const PlayerScreen({super.key, required this.videoId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  VideoController? _videoController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    _videoController = null;
    super.dispose();
  }

  Future<void> _initPlayer() async {
    final player = ref.read(playerProvider);
    _videoController = VideoController(player);

    final video = await ref.read(videoRepositoryProvider).getVideo(widget.videoId);
    if (video == null || !mounted) return;

    await ref.read(playerNotifierProvider.notifier).loadVideo(
          videoPath: video.filePath,
          subtitlePath: video.subtitlePath,
          subtitleOffsetMs: video.subtitleOffsetMs,
        );

    if (mounted) setState(() {});
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video area
            Expanded(
              child: GestureDetector(
                onTap: _toggleControls,
                child: Stack(
                  children: [
                    if (_videoController != null)
                      Center(
                        child: Video(
                          controller: _videoController!,
                          controls: (state) => const SizedBox.shrink(),
                        ),
                      ),

                    // Subtitle overlay (always visible over video)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 48,
                      child: SubtitleOverlay(videoId: widget.videoId),
                    ),

                    // Top bar
                    if (_showControls)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _TopBar(videoId: widget.videoId),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom controls
            if (_showControls)
              _BottomControls(videoId: widget.videoId),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final String videoId;
  const _TopBar({required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              ref.read(playerNotifierProvider.notifier).pause();
              Navigator.of(context).pop();
            },
          ),
          const Spacer(),
          // Subtitle offset control
          _SubtitleOffsetButton(videoId: videoId),
          // Import subtitle
          _ImportSubtitleButton(videoId: videoId),
        ],
      ),
    );
  }
}

class _SubtitleOffsetButton extends ConsumerWidget {
  final String videoId;
  const _SubtitleOffsetButton({required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.tune, color: Colors.white),
      tooltip: '字幕偏移',
      onPressed: () => _showOffsetDialog(context, ref),
    );
  }

  void _showOffsetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _OffsetDialog(
        onChanged: (ms) {
          ref.read(playerNotifierProvider.notifier).setSubtitleOffset(ms);
          ref.read(videoRepositoryProvider).updateSubtitleOffset(videoId, ms);
        },
      ),
    );
  }
}

class _OffsetDialog extends StatefulWidget {
  final void Function(int ms) onChanged;
  const _OffsetDialog({required this.onChanged});

  @override
  State<_OffsetDialog> createState() => _OffsetDialogState();
}

class _OffsetDialogState extends State<_OffsetDialog> {
  double _offsetSec = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('字幕偏移调节'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${_offsetSec > 0 ? '+' : ''}${_offsetSec.toStringAsFixed(1)}秒'),
          Slider(
            value: _offsetSec,
            min: -5,
            max: 5,
            divisions: 100,
            onChanged: (v) {
              setState(() => _offsetSec = v);
              widget.onChanged((v * 1000).round());
            },
          ),
          const Text('负值=字幕提前，正值=字幕延迟', style: TextStyle(fontSize: 12)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

class _ImportSubtitleButton extends ConsumerWidget {
  final String videoId;
  const _ImportSubtitleButton({required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.subtitles, color: Colors.white),
      tooltip: '导入字幕',
      onPressed: () async {
        final path = await ref
            .read(videoRepositoryProvider)
            .importSubtitle(videoId);
        if (path != null && context.mounted) {
          // Reload player with new subtitle
          final video = await ref.read(videoRepositoryProvider).getVideo(videoId);
          if (video != null) {
            await ref.read(playerNotifierProvider.notifier).loadVideo(
                  videoPath: video.filePath,
                  subtitlePath: path,
                );
          }
        }
      },
    );
  }
}

class _BottomControls extends ConsumerStatefulWidget {
  final String videoId;
  const _BottomControls({required this.videoId});

  @override
  ConsumerState<_BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends ConsumerState<_BottomControls> {
  bool _isDragging = false;
  double _dragValue = 0.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<bool>? _playSub;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    final player = ref.read(playerProvider);
    _posSub = player.stream.position.listen((pos) {
      if (!_isDragging && mounted) {
        setState(() => _position = pos);
      }
    });
    _durSub = player.stream.duration.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
    _playSub = player.stream.playing.listen((playing) {
      if (mounted) setState(() => _playing = playing);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _playSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    final displayValue = _isDragging ? _dragValue : progress.clamp(0.0, 1.0);
    final displayPos = _isDragging
        ? Duration(milliseconds: (_dragValue * _duration.inMilliseconds).round())
        : _position;

    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: displayValue.clamp(0.0, 1.0),
              onChangeStart: (v) {
                setState(() {
                  _isDragging = true;
                  _dragValue = v;
                });
              },
              onChanged: (v) {
                setState(() => _dragValue = v);
              },
              onChangeEnd: (v) {
                final target = Duration(
                  milliseconds: (v * _duration.inMilliseconds).round(),
                );
                ref.read(playerNotifierProvider.notifier).seek(target);
                setState(() {
                  _isDragging = false;
                  _position = target;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(displayPos),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                Text(_formatDuration(_duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),

          // Play controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () {
                  final target = _position - const Duration(seconds: 10);
                  ref.read(playerNotifierProvider.notifier).seek(target);
                },
              ),
              IconButton(
                iconSize: 48,
                icon: Icon(
                  _playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                onPressed: () =>
                    ref.read(playerNotifierProvider.notifier).togglePlayPause(),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () {
                  final target = _position + const Duration(seconds: 10);
                  ref.read(playerNotifierProvider.notifier).seek(target);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
