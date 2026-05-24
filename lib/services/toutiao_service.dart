import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ToutiaoVideoInfo {
  final String title;
  final String videoUrl;
  final double? duration;

  const ToutiaoVideoInfo({
    required this.title,
    required this.videoUrl,
    this.duration,
  });
}

class ToutiaoService {
  static const _desktopUA =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  static const _mobileUA =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  static bool isToutiaoUrl(String url) {
    return url.contains('toutiao.com') ||
        url.contains('douyin.com') ||
        url.contains('ixigua.com');
  }

  static Future<String> resolveShortUrl(String url) async {
    final shortDomains = ['m.toutiao.com/is', 'v.douyin.com'];
    final isShort = shortDomains.any((d) => url.contains(d));
    if (!isShort) return url;

    try {
      final client = HttpClient();
      client.userAgent = _mobileUA;
      final request = await client.getUrl(Uri.parse(url));
      request.followRedirects = false;
      final response = await request.close();
      await response.drain();
      client.close();

      final location = response.headers.value('location');
      if (location != null && location.startsWith('http')) {
        return location;
      }
    } catch (e) {
      debugPrint('[Toutiao] resolveShortUrl error: $e');
    }
    return url;
  }

  static String? _extractArticleId(String url) {
    final match = RegExp(r'/(?:video|a|i)/(\d+)').firstMatch(url);
    return match?.group(1);
  }

  static Future<ToutiaoVideoInfo?> fetchVideoInfo(String url) async {
    try {
      // Step 1: Resolve short URL to get article ID
      final resolvedUrl = await resolveShortUrl(url);
      debugPrint('[Toutiao] resolved URL: $resolvedUrl');

      final articleId = _extractArticleId(resolvedUrl);
      if (articleId == null) {
        debugPrint('[Toutiao] Could not extract article ID from: $resolvedUrl');
        return null;
      }

      // Step 2: Fetch desktop page to get RENDER_DATA with video URLs
      final desktopUrl = 'https://www.toutiao.com/video/$articleId/';
      final response = await http.get(
        Uri.parse(desktopUrl),
        headers: {
          'User-Agent': _desktopUA,
          'Cookie': 'tt_webid=1; ttwid=1',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('[Toutiao] Desktop page HTTP ${response.statusCode}');
        return null;
      }

      final html = response.body;

      // Step 3: Extract RENDER_DATA (URL-encoded JSON in script tag)
      final renderMatch = RegExp(
        r'<script id="RENDER_DATA"[^>]*>(.*?)</script>',
      ).firstMatch(html);

      if (renderMatch == null) {
        debugPrint('[Toutiao] No RENDER_DATA found');
        return null;
      }

      final decoded = Uri.decodeFull(renderMatch.group(1)!);

      // Step 4: Extract title
      final titleMatch = RegExp(r'"title"\s*:\s*"([^"]{3,100})"').firstMatch(decoded);
      final title = titleMatch?.group(1) ?? 'Untitled';

      // Step 5: Extract video URLs (main_url entries are direct MP4 CDN links)
      final urlMatches = RegExp(r'"main_url"\s*:\s*"([^"]+)"').allMatches(decoded);
      if (urlMatches.isEmpty) {
        debugPrint('[Toutiao] No main_url found in RENDER_DATA');
        return null;
      }

      // Use the last URL (typically highest quality)
      final videoUrl = urlMatches.last.group(1)!;
      debugPrint('[Toutiao] Found ${urlMatches.length} video URLs, using last one');

      return ToutiaoVideoInfo(
        title: title,
        videoUrl: videoUrl,
      );
    } catch (e) {
      debugPrint('[Toutiao] fetchVideoInfo error: $e');
      return null;
    }
  }

  static Future<String?> downloadVideo(
    String videoUrl,
    String outputPath, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(videoUrl));
      request.headers['User-Agent'] = _desktopUA;
      request.headers['Referer'] = 'https://www.toutiao.com/';

      final client = http.Client();
      final response = await client.send(request);

      if (response.statusCode != 200) {
        debugPrint('[Toutiao] download HTTP ${response.statusCode}');
        client.close();
        return null;
      }

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;
      final file = File(outputPath);
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.close();
      client.close();

      if (await file.exists() && await file.length() > 0) {
        return outputPath;
      }
      return null;
    } catch (e) {
      debugPrint('[Toutiao] downloadVideo error: $e');
      return null;
    }
  }
}
