import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/word_audio_service.dart';

class PhoneticButton extends ConsumerStatefulWidget {
  final String phonetic;
  final String audioUrl;

  const PhoneticButton({
    super.key,
    required this.phonetic,
    required this.audioUrl,
  });

  @override
  ConsumerState<PhoneticButton> createState() => _PhoneticButtonState();
}

class _PhoneticButtonState extends ConsumerState<PhoneticButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_playing) return;
    setState(() => _playing = true);
    _controller.repeat();
    ref.read(wordAudioServiceProvider).play(widget.audioUrl);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      _controller.stop();
      _controller.reset();
      setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.phonetic.isEmpty) return const SizedBox.shrink();

    final hasAudio = widget.audioUrl.isNotEmpty;

    return GestureDetector(
      onTap: hasAudio ? _play : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.phonetic,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textTertiary,
            ),
          ),
          if (hasAudio) ...[
            const SizedBox(width: 6),
            _AnimatedSpeaker(
              controller: _controller,
              playing: _playing,
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedSpeaker extends StatelessWidget {
  final AnimationController controller;
  final bool playing;

  const _AnimatedSpeaker({
    required this.controller,
    required this.playing,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primaryBlue;

    if (!playing) {
      return Icon(
        Icons.volume_up_rounded,
        size: 18,
        color: color.withAlpha(180),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        return SizedBox(
          width: 22,
          height: 18,
          child: CustomPaint(
            painter: _SpeakerWavePainter(
              progress: t,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

class _SpeakerWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SpeakerWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Speaker body (left triangle + rect)
    final speakerPath = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.15, size.height * 0.3)
      ..lineTo(size.width * 0.35, size.height * 0.1)
      ..lineTo(size.width * 0.35, size.height * 0.9)
      ..lineTo(size.width * 0.15, size.height * 0.7)
      ..lineTo(0, size.height * 0.7)
      ..close();
    canvas.drawPath(speakerPath, paint);

    // Sound waves with animated opacity
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final cx = size.width * 0.4;
    final cy = size.height * 0.5;

    // Wave 1 (small)
    final wave1Alpha = _waveAlpha(progress, 0.0);
    if (wave1Alpha > 0) {
      wavePaint.color = color.withAlpha((wave1Alpha * 220).toInt());
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: 10, height: 12),
        -0.8,
        1.6,
        false,
        wavePaint,
      );
    }

    // Wave 2 (medium)
    final wave2Alpha = _waveAlpha(progress, 0.25);
    if (wave2Alpha > 0) {
      wavePaint.color = color.withAlpha((wave2Alpha * 180).toInt());
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: 18, height: 18),
        -0.8,
        1.6,
        false,
        wavePaint,
      );
    }

    // Wave 3 (large)
    final wave3Alpha = _waveAlpha(progress, 0.5);
    if (wave3Alpha > 0) {
      wavePaint.color = color.withAlpha((wave3Alpha * 140).toInt());
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: 26, height: 24),
        -0.8,
        1.6,
        false,
        wavePaint,
      );
    }
  }

  double _waveAlpha(double t, double offset) {
    final v = (t + offset) % 1.0;
    if (v < 0.5) return v * 2;
    return (1.0 - v) * 2;
  }

  @override
  bool shouldRepaint(_SpeakerWavePainter old) => old.progress != progress;
}
