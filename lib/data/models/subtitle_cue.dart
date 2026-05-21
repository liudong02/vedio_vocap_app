class SubtitleCue {
  final int index;
  final Duration start;
  final Duration end;
  final String text;
  final List<WordToken> words;

  const SubtitleCue({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
    required this.words,
  });

  bool containsPosition(Duration position) =>
      position >= start && position <= end;
}

class WordToken {
  final String display;
  final String lookup;
  final bool isSpace;

  const WordToken({
    required this.display,
    required this.lookup,
    this.isSpace = false,
  });

  static WordToken space() => const WordToken(display: ' ', lookup: '', isSpace: true);
}
