import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BilibiliVideoInfo {
  final String title;
  final int aid;
  final String bvid;
  final double duration;
  final List<BilibiliPage> pages;

  const BilibiliVideoInfo({
    required this.title,
    required this.aid,
    required this.bvid,
    required this.duration,
    required this.pages,
  });
}

class BilibiliPage {
  final int cid;
  final int page;
  final String partName;
  final double duration;

  const BilibiliPage({
    required this.cid,
    required this.page,
    required this.partName,
    required this.duration,
  });
}

class BilibiliService {
  static const _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static bool isBilibiliUrl(String url) {
    return url.contains('bilibili.com') || url.contains('b23.tv');
  }

  static String? extractBvid(String url) {
    final match = RegExp(r'(BV[\w]+)').firstMatch(url);
    return match?.group(1);
  }

  static Future<String> resolveShortUrl(String url) async {
    if (!url.contains('b23.tv')) return url;
    try {
      final request = http.Request('GET', Uri.parse(url))
        ..followRedirects = false
        ..headers['User-Agent'] = _userAgent;
      final client = http.Client();
      final response = await client.send(request);
      client.close();
      final location = response.headers['location'];
      if (location != null && location.startsWith('http')) {
        return location;
      }
    } catch (e) {
      debugPrint('[Bilibili] resolveShortUrl error: $e');
    }
    return url;
  }

  static Future<BilibiliVideoInfo?> fetchVideoInfo(String bvid) async {
    try {
      final uri = Uri.parse(
          'https://api.bilibili.com/x/web-interface/view?bvid=$bvid');
      final response = await http.get(uri, headers: {
        'User-Agent': _userAgent,
        'Referer': 'https://www.bilibili.com/',
      });

      if (response.statusCode != 200) {
        debugPrint('[Bilibili] fetchVideoInfo HTTP ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final code = json['code'] as int?;
      if (code != 0) {
        debugPrint('[Bilibili] API error code=$code msg=${json['message']}');
        return null;
      }

      final data = json['data'] as Map<String, dynamic>;
      final pages = (data['pages'] as List<dynamic>?)
              ?.map((p) => BilibiliPage(
                    cid: p['cid'] as int,
                    page: p['page'] as int,
                    partName: p['part'] as String? ?? '',
                    duration: (p['duration'] as num?)?.toDouble() ?? 0,
                  ))
              .toList() ??
          [];

      return BilibiliVideoInfo(
        title: data['title'] as String? ?? 'Untitled',
        aid: data['aid'] as int,
        bvid: bvid,
        duration: (data['duration'] as num?)?.toDouble() ?? 0,
        pages: pages,
      );
    } catch (e) {
      debugPrint('[Bilibili] fetchVideoInfo error: $e');
      return null;
    }
  }

  static Future<String?> getStreamUrl(int aid, int cid) async {
    try {
      final uri = Uri.parse(
          'https://api.bilibili.com/x/player/playurl?avid=$aid&cid=$cid&qn=64&fnval=1');
      final response = await http.get(uri, headers: {
        'User-Agent': _userAgent,
        'Referer': 'https://www.bilibili.com/',
      });

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['code'] != 0) return null;

      final data = json['data'] as Map<String, dynamic>;
      final durl = data['durl'] as List<dynamic>?;
      if (durl == null || durl.isEmpty) return null;

      return durl[0]['url'] as String?;
    } catch (e) {
      debugPrint('[Bilibili] getStreamUrl error: $e');
      return null;
    }
  }

  static Future<String?> downloadStream(
      String streamUrl, String outputPath) async {
    try {
      final request = http.Request('GET', Uri.parse(streamUrl));
      request.headers['User-Agent'] = _userAgent;
      request.headers['Referer'] = 'https://www.bilibili.com/';

      final client = http.Client();
      final response = await client.send(request);

      if (response.statusCode != 200) {
        debugPrint('[Bilibili] download HTTP ${response.statusCode}');
        client.close();
        return null;
      }

      final file = File(outputPath);
      final sink = file.openWrite();
      await response.stream.pipe(sink);
      await sink.close();
      client.close();

      if (await file.exists() && await file.length() > 0) {
        return outputPath;
      }
      return null;
    } catch (e) {
      debugPrint('[Bilibili] downloadStream error: $e');
      return null;
    }
  }

  /// Convert FLV to MP4 using ffmpeg (Bilibili streams are often FLV)
  static Future<String?> convertToMp4(
      String inputPath, String outputPath) async {
    try {
      final result = await Process.run('ffmpeg', [
        '-i', inputPath,
        '-c', 'copy',
        '-y',
        outputPath,
      ]);
      if (result.exitCode == 0 && await File(outputPath).exists()) {
        await File(inputPath).delete();
        return outputPath;
      }
      debugPrint('[Bilibili] ffmpeg convert error: ${result.stderr}');
      return inputPath;
    } catch (e) {
      debugPrint('[Bilibili] ffmpeg not available: $e');
      return inputPath;
    }
  }
}
