import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/subtitle_cue.dart';
import '../../services/player_service.dart';
import 'word_popup.dart';

class SubtitleOverlay extends ConsumerStatefulWidget {
  final String videoId;
  const SubtitleOverlay({super.key, required this.videoId});

  @override
  ConsumerState<SubtitleOverlay> createState() => _SubtitleOverlayState();
}

class _SubtitleOverlayState extends ConsumerState<SubtitleOverlay> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cue = ref.watch(activeCueProvider);
    if (cue == null) return const SizedBox.shrink();

    return _buildSubtitle(context, cue);
  }

  Widget _buildSubtitle(BuildContext context, SubtitleCue cue) {
    _disposeRecognizers();

    final fontSize = _subtitleFontSize(context);
    final plainStyle = TextStyle(
      fontFamily: 'Inter',
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      height: 1.35,
      shadows: _subtitleShadows,
    );
    final wordStyle = plainStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: const Color(0xAAB794FF),
      decorationThickness: 1.5,
    );

    final spans = <InlineSpan>[];
    for (final token in cue.words) {
      if (token.isSpace || token.lookup.isEmpty) {
        spans.add(TextSpan(
          text: token.display,
          style: plainStyle,
        ));
      } else {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => _onWordTap(context, token.lookup, cue);
        _recognizers.add(recognizer);

        spans.add(TextSpan(
          text: token.display,
          style: wordStyle,
          recognizer: recognizer,
        ));
      }
    }

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: spans),
      ),
    );
  }

  void _onWordTap(BuildContext context, String word, SubtitleCue cue) {
    ref.read(playerNotifierProvider.notifier).pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => WordPopup(
        word: word,
        context: cue.text,
        videoId: widget.videoId,
        videoPositionMs: ref.read(playerProvider).state.position.inMilliseconds,
      ),
    ).then((_) {
      ref.read(playerNotifierProvider.notifier).play();
    });
  }

  static double _subtitleFontSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return 16;
    if (w < 1024) return 20;
    return 24;
  }

  static const _subtitleShadows = [
    Shadow(offset: Offset(-1.5, -1.5), blurRadius: 1, color: Colors.black),
    Shadow(offset: Offset(1.5, -1.5), blurRadius: 1, color: Colors.black),
    Shadow(offset: Offset(-1.5, 1.5), blurRadius: 1, color: Colors.black),
    Shadow(offset: Offset(1.5, 1.5), blurRadius: 1, color: Colors.black),
    Shadow(blurRadius: 4, color: Color(0xDD000000)),
  ];
}
