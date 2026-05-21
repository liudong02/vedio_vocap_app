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
    ref.read(playerNotifierProvider.notifier).pause();
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
                        child: Video(controller: _videoController!),
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
            onPressed: () => Navigator.of(context).pop(),
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

class _BottomControls extends ConsumerWidget {
  final String videoId;
  const _BottomControls({required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          StreamBuilder<Duration>(
            stream: player.stream.position,
            builder: (context, posSnap) {
              return StreamBuilder<Duration>(
                stream: player.stream.duration,
                builder: (context, durSnap) {
                  final pos = posSnap.data ?? Duration.zero;
                  final dur = durSnap.data ?? Duration.zero;
                  final progress =
                      dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (v) {
                            final target = Duration(
                              milliseconds: (v * dur.inMilliseconds).round(),
                            );
                            ref.read(playerNotifierProvider.notifier).seek(target);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(pos),
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                            Text(_formatDuration(dur),
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          // Play controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () {
                  final pos = player.state.position;
                  ref.read(playerNotifierProvider.notifier)
                      .seek(pos - const Duration(seconds: 10));
                },
              ),
              StreamBuilder<bool>(
                stream: player.stream.playing,
                builder: (context, snap) {
                  final playing = snap.data ?? false;
                  return IconButton(
                    iconSize: 48,
                    icon: Icon(
                      playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        ref.read(playerNotifierProvider.notifier).togglePlayPause(),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () {
                  final pos = player.state.position;
                  ref.read(playerNotifierProvider.notifier)
                      .seek(pos + const Duration(seconds: 10));
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
