import '../../data/models/subtitle_cue.dart';

class SrtParser {
  static List<SubtitleCue> parse(String content) {
    // Normalize line endings and strip BOM
    final text = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceFirst('﻿', '');

    final cues = <SubtitleCue>[];
    final blocks = text.split(RegExp(r'\n\n+'));

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 2) continue;

      // Find the timestamp line (contains '-->'), skip sequence number
      int tsLineIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('-->')) {
          tsLineIndex = i;
          break;
        }
      }
      if (tsLineIndex == -1) continue;

      final timestamps = _parseTimestampLine(lines[tsLineIndex]);
      if (timestamps == null) continue;

      final rawText = lines.sublist(tsLineIndex + 1).join('\n').trim();
      if (rawText.isEmpty) continue;

      final plainText = _stripTags(rawText);
      final index = cues.length;

      cues.add(SubtitleCue(
        index: index,
        start: timestamps.$1,
        end: timestamps.$2,
        text: plainText,
        words: _tokenize(plainText),
      ));
    }

    cues.sort((a, b) => a.start.compareTo(b.start));
    return cues;
  }

  // Returns (start, end) or null if unparseable
  static (Duration, Duration)? _parseTimestampLine(String line) {
    // SRT: 00:01:23,456 --> 00:01:25,000
    // VTT: 00:01:23.456 --> 00:01:25.000 [optional cue settings]
    final parts = line.split('-->');
    if (parts.length < 2) return null;
    final start = _parseDuration(parts[0].trim());
    final end = _parseDuration(parts[1].trim().split(' ').first);
    if (start == null || end == null) return null;
    return (start, end);
  }

  static Duration? _parseDuration(String ts) {
    // Handles HH:MM:SS,mmm and HH:MM:SS.mmm and MM:SS.mmm
    final pattern = RegExp(
      r'(?:(\d{1,2}):)?(\d{1,2}):(\d{2})[,.](\d{3})',
    );
    final match = pattern.firstMatch(ts);
    if (match == null) return null;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    final ms = int.tryParse(match.group(4) ?? '0') ?? 0;

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: ms,
    );
  }

  static String _stripTags(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\{[^}]+\}'), '') // ASS tags
        .trim();
  }

  static List<WordToken> _tokenize(String text) {
    final tokens = <WordToken>[];
    final matches = RegExp(r'\S+|\s+').allMatches(text);

    for (final match in matches) {
      final raw = match.group(0)!;
      if (raw.trim().isEmpty) {
        tokens.add(WordToken.space());
      } else {
        // Separate leading/trailing punctuation from the word
        final wordMatch = RegExp(r"^([^a-zA-Z']*)([a-zA-Z'][a-zA-Z'-]*)([^a-zA-Z']*)$")
            .firstMatch(raw);

        if (wordMatch != null) {
          final prefix = wordMatch.group(1)!;
          final word = wordMatch.group(2)!;
          // group(3) is suffix — included in display, not added separately

          if (prefix.isNotEmpty) {
            tokens.add(WordToken(display: prefix, lookup: '', isSpace: true));
          }
          tokens.add(WordToken(
            display: raw, // show full token including punctuation
            lookup: word.toLowerCase(),
          ));
          // suffix is included in display; don't add separately
        } else {
          // Pure punctuation or number — not clickable
          tokens.add(WordToken(display: raw, lookup: '', isSpace: true));
        }
      }
    }

    return tokens;
  }
}
