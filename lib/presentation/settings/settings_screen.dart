import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../services/upgrade_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
              child: Text(
                '设置',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            _SectionCard(
              children: [
                _SettingsTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: '反馈与建议',
                  subtitle: '扫码添加微信好友',
                  onTap: () => _showFeedbackSheet(context),
                ),
                const Divider(height: 1, indent: 52),
                _SettingsTile(
                  icon: Icons.system_update_outlined,
                  title: '检查更新',
                  subtitle: '检查是否有新版本',
                  onTap: () => _checkUpdate(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: '关于',
                  subtitle: '版本信息',
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '扫码添加微信好友',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '有任何问题或建议，欢迎联系我',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/wechat_qr.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_rounded, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('二维码待配置', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _checkUpdate(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final update = await UpgradeService.checkForUpdate();

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (update == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已是最新版本')),
      );
      return;
    }

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: Text('发现新版本 v${update.version}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (update.changelog.isNotEmpty) ...[
              const Text('更新内容：',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(update.changelog),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍后'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startUpgrade(context, update);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  void _startUpgrade(BuildContext context, UpdateInfo update) {
    if (Platform.isIOS) {
      UpgradeService.downloadAndInstall(
        update,
        state: ValueNotifier(
            const UpgradeState(step: UpgradeStep.downloading)),
      );
      return;
    }

    final stateNotifier = ValueNotifier<UpgradeState>(
      const UpgradeState(step: UpgradeStep.downloading, progress: 0),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => PopScope(
        canPop: false,
        child: ValueListenableBuilder<UpgradeState>(
          valueListenable: stateNotifier,
          builder: (context, state, _) {
            return AlertDialog(
              title: const Text('正在更新'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _UpgradeStepRow(
                    label: '下载更新包',
                    stepState: _stepState(state, UpgradeStep.downloading),
                  ),
                  if (state.step == UpgradeStep.downloading &&
                      state.progress != null)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 36, right: 8, bottom: 8),
                      child: LinearProgressIndicator(
                          value: state.progress),
                    ),
                  if (!Platform.isAndroid) ...[
                    _UpgradeStepRow(
                      label: '解压文件',
                      stepState: _stepState(state, UpgradeStep.extracting),
                    ),
                    _UpgradeStepRow(
                      label: '安装更新',
                      stepState: _stepState(state, UpgradeStep.installing),
                    ),
                    _UpgradeStepRow(
                      label: '重启应用',
                      stepState: _stepState(state, UpgradeStep.restarting),
                    ),
                  ],
                  if (Platform.isAndroid)
                    _UpgradeStepRow(
                      label: '安装应用',
                      stepState: _stepState(state, UpgradeStep.installing),
                    ),
                  if (state.step == UpgradeStep.error) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error ?? '未知错误',
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ],
              ),
              actions: [
                if (state.step == UpgradeStep.error ||
                    state.step == UpgradeStep.done)
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('关闭'),
                  ),
              ],
            );
          },
        ),
      ),
    );

    UpgradeService.downloadAndInstall(update, state: stateNotifier);
  }

  _StepState _stepState(UpgradeState current, UpgradeStep target) {
    final steps = Platform.isAndroid
        ? [UpgradeStep.downloading, UpgradeStep.installing, UpgradeStep.done]
        : [
            UpgradeStep.downloading,
            UpgradeStep.extracting,
            UpgradeStep.installing,
            UpgradeStep.restarting,
            UpgradeStep.done,
          ];

    final currentIdx = steps.indexOf(current.step);
    final targetIdx = steps.indexOf(target);

    if (current.step == UpgradeStep.error) {
      if (targetIdx <= currentIdx || targetIdx == -1) return _StepState.error;
      return _StepState.pending;
    }

    if (targetIdx < currentIdx) return _StepState.completed;
    if (targetIdx == currentIdx) return _StepState.active;
    return _StepState.pending;
  }

  void _showAbout(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('关于'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('视频词汇学习',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('版本: ${info.version} (${info.buildNumber})'),
            const SizedBox(height: 4),
            const Text('看视频学英语，轻松记单词',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

enum _StepState { pending, active, completed, error }

class _UpgradeStepRow extends StatelessWidget {
  final String label;
  final _StepState stepState;

  const _UpgradeStepRow({required this.label, required this.stepState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: switch (stepState) {
              _StepState.completed => const Icon(
                  Icons.check_circle, color: Colors.green, size: 20),
              _StepState.active => const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(strokeWidth: 2)),
              _StepState.error => const Icon(
                  Icons.error, color: Colors.red, size: 20),
              _StepState.pending => Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey[400],
                  size: 20),
            },
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: stepState == _StepState.pending
                  ? Colors.grey
                  : null,
              fontWeight: stepState == _StepState.active
                  ? FontWeight.w600
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryBlue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
