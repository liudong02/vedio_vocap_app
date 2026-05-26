import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String version;
  final int buildNumber;
  final String changelog;
  final Map<String, String> downloadUrl;

  const UpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.changelog,
    required this.downloadUrl,
  });

  String? get platformDownloadUrl {
    if (Platform.isAndroid) return downloadUrl['android'];
    if (Platform.isIOS) return downloadUrl['ios'];
    if (Platform.isMacOS) return downloadUrl['macos'];
    if (Platform.isWindows) return downloadUrl['windows'];
    if (Platform.isLinux) return downloadUrl['linux'];
    return null;
  }
}

class UpgradeService {
  // TODO: Replace with your actual version.json URL
  static const _versionUrl = 'https://example.com/video_vocab/version.json';

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));
      if (response.statusCode != 200) {
        debugPrint('[Upgrade] HTTP ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final remoteVersion = data['version'] as String;
      final remoteBuild = data['buildNumber'] as int? ?? 0;
      final changelog = data['changelog'] as String? ?? '';
      final urls = (data['downloadUrl'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {};

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewer(remoteVersion, currentVersion)) {
        return UpdateInfo(
          version: remoteVersion,
          buildNumber: remoteBuild,
          changelog: changelog,
          downloadUrl: urls,
        );
      }
      return null;
    } catch (e) {
      debugPrint('[Upgrade] checkForUpdate error: $e');
      return null;
    }
  }

  static bool _isNewer(String remote, String current) {
    final r = remote.split('.').map(int.tryParse).toList();
    final c = current.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final rv = i < r.length ? (r[i] ?? 0) : 0;
      final cv = i < c.length ? (c[i] ?? 0) : 0;
      if (rv > cv) return true;
      if (rv < cv) return false;
    }
    return false;
  }
}
