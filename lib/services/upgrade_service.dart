import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';

enum UpgradeStep { downloading, extracting, installing, restarting, done, error }

class UpgradeState {
  final UpgradeStep step;
  final double? progress;
  final String? error;

  const UpgradeState({required this.step, this.progress, this.error});
}

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
  static const _releaseApiUrl =
      'https://api.github.com/repos/liudong02/vedio_vocap_app/releases/latest';

  static const _assetPlatformMap = {
    'VideoVocab-android.apk': 'android',
    'VideoVocab-iOS.zip': 'ios',
    'VideoVocab-macOS.zip': 'macos',
    'VideoVocab-Windows.zip': 'windows',
  };

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(_releaseApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      if (response.statusCode != 200) {
        debugPrint('[Upgrade] GitHub API HTTP ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['draft'] == true || data['prerelease'] == true) {
        return null;
      }

      final tagName = data['tag_name'] as String;
      final remoteVersion =
          tagName.startsWith('v') ? tagName.substring(1) : tagName;
      final changelog = data['body'] as String? ?? '';

      final assets = data['assets'] as List<dynamic>? ?? [];
      final downloadUrls = <String, String>{};
      for (final asset in assets) {
        final name = asset['name'] as String;
        final url = asset['browser_download_url'] as String;
        final platform = _assetPlatformMap[name];
        if (platform != null) {
          downloadUrls[platform] = url;
        }
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewer(remoteVersion, currentVersion)) {
        return UpdateInfo(
          version: remoteVersion,
          buildNumber: 0,
          changelog: changelog,
          downloadUrl: downloadUrls,
        );
      }
      return null;
    } catch (e) {
      debugPrint('[Upgrade] checkForUpdate error: $e');
      return null;
    }
  }

  static Future<void> downloadAndInstall(
    UpdateInfo update, {
    required ValueNotifier<UpgradeState> state,
  }) async {
    try {
      if (Platform.isIOS) {
        final url = update.platformDownloadUrl;
        if (url != null) {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
        return;
      }

      final url = update.platformDownloadUrl;
      if (url == null) {
        state.value =
            const UpgradeState(step: UpgradeStep.error, error: '当前平台暂无下载资源');
        return;
      }

      // Step 1: Download
      state.value = const UpgradeState(step: UpgradeStep.downloading);
      final tempDir = await getTemporaryDirectory();
      final fileName = Platform.isAndroid
          ? 'VideoVocab-update.apk'
          : 'VideoVocab-update.zip';
      final downloadPath = p.join(tempDir.path, fileName);
      final file = File(downloadPath);

      await _downloadFile(url, file, (progress) {
        state.value =
            UpgradeState(step: UpgradeStep.downloading, progress: progress);
      });

      if (Platform.isAndroid) {
        await _installAndroid(downloadPath, state);
      } else if (Platform.isMacOS) {
        await _installMacOS(downloadPath, tempDir.path, state);
      } else if (Platform.isWindows) {
        await _installWindows(downloadPath, tempDir.path, state);
      }
    } catch (e) {
      state.value =
          UpgradeState(step: UpgradeStep.error, error: e.toString());
    }
  }

  static Future<void> _downloadFile(
    String url,
    File file,
    void Function(double) onProgress,
  ) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('下载失败: HTTP ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.close();
    } finally {
      client.close();
    }
  }

  static Future<void> _installAndroid(
    String apkPath,
    ValueNotifier<UpgradeState> state,
  ) async {
    state.value = const UpgradeState(step: UpgradeStep.installing);
    final result = await OpenFilex.open(apkPath,
        type: 'application/vnd.android.package-archive');
    if (result.type != ResultType.done) {
      state.value = UpgradeState(
          step: UpgradeStep.error, error: '无法打开安装器: ${result.message}');
    } else {
      state.value = const UpgradeState(step: UpgradeStep.done);
    }
  }

  static Future<void> _installMacOS(
    String zipPath,
    String tempDir,
    ValueNotifier<UpgradeState> state,
  ) async {
    // Step 2: Extract
    state.value = const UpgradeState(step: UpgradeStep.extracting);
    final extractDir = p.join(tempDir, 'upgrade_extract');
    final extractDirObj = Directory(extractDir);
    if (extractDirObj.existsSync()) {
      extractDirObj.deleteSync(recursive: true);
    }
    extractDirObj.createSync();

    final unzipResult =
        await Process.run('/usr/bin/ditto', ['-xk', zipPath, extractDir]);
    if (unzipResult.exitCode != 0) {
      state.value = UpgradeState(
          step: UpgradeStep.error,
          error: '解压失败: ${unzipResult.stderr}');
      return;
    }

    // Find the .app bundle in extracted directory
    final appDir = Directory(extractDir)
        .listSync()
        .whereType<Directory>()
        .where((d) => d.path.endsWith('.app'))
        .firstOrNull;

    if (appDir == null) {
      state.value =
          const UpgradeState(step: UpgradeStep.error, error: '解压内容中未找到 .app');
      return;
    }

    // Step 3: Install - get current app path
    state.value = const UpgradeState(step: UpgradeStep.installing);
    final currentAppPath = _getMacOSAppBundlePath();
    if (currentAppPath == null) {
      state.value =
          const UpgradeState(step: UpgradeStep.error, error: '无法定位当前应用路径');
      return;
    }

    // Write a shell script to replace the app after this process exits
    final scriptPath = p.join(tempDir, 'upgrade.sh');
    final script = '''#!/bin/bash
sleep 2
rm -rf ${_shellEscape(currentAppPath)}
mv ${_shellEscape(appDir.path)} ${_shellEscape(currentAppPath)}
open -n ${_shellEscape(currentAppPath)}
rm -f ${_shellEscape(scriptPath)}
''';
    File(scriptPath).writeAsStringSync(script);

    state.value = const UpgradeState(step: UpgradeStep.restarting);
    await Process.start('bash', [scriptPath],
        mode: ProcessStartMode.detached);
    exit(0);
  }

  static Future<void> _installWindows(
    String zipPath,
    String tempDir,
    ValueNotifier<UpgradeState> state,
  ) async {
    // Step 2: Extract
    state.value = const UpgradeState(step: UpgradeStep.extracting);
    final extractDir = p.join(tempDir, 'upgrade_extract');
    final extractDirObj = Directory(extractDir);
    if (extractDirObj.existsSync()) {
      extractDirObj.deleteSync(recursive: true);
    }
    extractDirObj.createSync();

    final unzipResult = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      'Expand-Archive',
      '-Path',
      zipPath,
      '-DestinationPath',
      extractDir,
      '-Force',
    ]);
    if (unzipResult.exitCode != 0) {
      state.value = UpgradeState(
          step: UpgradeStep.error,
          error: '解压失败: ${unzipResult.stderr}');
      return;
    }

    // Step 3: Install
    state.value = const UpgradeState(step: UpgradeStep.installing);
    final currentExe = Platform.resolvedExecutable;
    final currentDir = p.dirname(currentExe);

    // Write a bat script to replace files after this process exits
    final scriptPath = p.join(tempDir, 'upgrade.bat');
    final script = '''@echo off
timeout /t 2 /nobreak >nul
xcopy /s /e /y "$extractDir\\*" "$currentDir\\" >nul
start "" "$currentExe"
del "%~f0"
''';
    File(scriptPath).writeAsStringSync(script);

    state.value = const UpgradeState(step: UpgradeStep.restarting);
    await Process.start('cmd', ['/c', scriptPath],
        mode: ProcessStartMode.detached);
    exit(0);
  }

  static String? _getMacOSAppBundlePath() {
    var dir = File(Platform.resolvedExecutable).parent;
    while (dir.path != '/' && dir.path.isNotEmpty) {
      if (dir.path.endsWith('.app')) return dir.path;
      dir = dir.parent;
    }
    return null;
  }

  static String _shellEscape(String s) {
    return "'${s.replaceAll("'", "'\\''")}'";
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
