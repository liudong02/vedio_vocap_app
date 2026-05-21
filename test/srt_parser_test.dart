import 'package:flutter_test/flutter_test.dart';
import 'package:video_vocab/core/utils/srt_parser.dart';

void main() {
  group('SrtParser', () {
    test('parses basic SRT block', () {
      const srt = '''
1
00:00:01,000 --> 00:00:03,500
Hello world

2
00:00:04,000 --> 00:00:06,000
How are you?
''';
      final cues = SrtParser.parse(srt);
      expect(cues.length, 2);
      expect(cues[0].start, const Duration(seconds: 1));
      expect(cues[0].end, const Duration(milliseconds: 3500));
      expect(cues[0].text, 'Hello world');
      expect(cues[1].start, const Duration(seconds: 4));
    });

    test('strips HTML tags', () {
      const srt = '''
1
00:00:01,000 --> 00:00:02,000
<i>Hello</i> <b>world</b>
''';
      final cues = SrtParser.parse(srt);
      expect(cues[0].text, 'Hello world');
    });

    test('handles BOM and CRLF', () {
      final srt = '﻿1\r\n00:00:01,000 --> 00:00:02,000\r\nHello\r\n\r\n';
      final cues = SrtParser.parse(srt);
      expect(cues.length, 1);
      expect(cues[0].text, 'Hello');
    });

    test('parses VTT-style dots in timestamps', () {
      const srt = '''
1
00:00:01.500 --> 00:00:03.000
Test
''';
      final cues = SrtParser.parse(srt);
      expect(cues[0].start, const Duration(milliseconds: 1500));
      expect(cues[0].end, const Duration(seconds: 3));
    });

    test('sorts cues by start time', () {
      const srt = '''
2
00:00:05,000 --> 00:00:06,000
Second

1
00:00:01,000 --> 00:00:02,000
First
''';
      final cues = SrtParser.parse(srt);
      expect(cues[0].text, 'First');
      expect(cues[1].text, 'Second');
    });

    test('tokenizes words correctly', () {
      const srt = '''
1
00:00:01,000 --> 00:00:02,000
Hello, world!
''';
      final cues = SrtParser.parse(srt);
      final words = cues[0].words.where((w) => !w.isSpace).toList();
      // "Hello," and "world!" should both be clickable
      expect(words.length, 2);
      expect(words[0].lookup, 'hello');
      expect(words[1].lookup, 'world');
    });

    test('pure punctuation tokens are non-clickable', () {
      const srt = '''
1
00:00:01,000 --> 00:00:02,000
"Hello"
''';
      final cues = SrtParser.parse(srt);
      final clickable = cues[0].words.where((w) => !w.isSpace).toList();
      expect(clickable.length, 1);
      expect(clickable[0].lookup, 'hello');
    });

    test('returns empty list for empty input', () {
      expect(SrtParser.parse(''), isEmpty);
    });

    test('skips blocks without timestamp line', () {
      const srt = '''
WEBVTT

1
00:00:01,000 --> 00:00:02,000
Hello
''';
      final cues = SrtParser.parse(srt);
      expect(cues.length, 1);
    });
  });
}
