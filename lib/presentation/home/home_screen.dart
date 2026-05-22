import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/database/app_database.dart';
import '../../services/video_import_service.dart';
import '../widgets/empty_state_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(videoRepositoryProvider).regenerateMissingThumbnails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videosStream = ref.watch(videoRepositoryProvider).watchAll();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<VideoEntry>>(
          stream: videosStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final videos = snapshot.data ?? [];
            if (videos.isEmpty) {
              return Column(
                children: [
                  _Header(count: 0, onImport: () => _showImportMenu(context)),
                  Expanded(
                    child: EmptyStateView(
                      icon: Icons.video_library_outlined,
                      title: '还没有视频',
                      subtitle: '导入视频开始学习英语',
                      actionLabel: '导入视频',
                      onAction: () => _showImportMenu(context),
                    ),
                  ),
                ],
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    count: videos.length,
                    onImport: () => _showImportMenu(context),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 16 / 10,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _VideoCard(video: videos[i]),
                      childCount: videos.length,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showImportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.folder_open_rounded),
                title: const Text('本地导入'),
                subtitle: const Text('从设备中选择视频文件'),
                onTap: () {
                  Navigator.pop(ctx);
                  _importLocalVideo(context);
                },
              ),
              if (VideoImportService.isDesktop)
                ListTile(
                  leading: const Icon(Icons.link_rounded),
                  title: const Text('粘贴链接'),
                  subtitle: const Text('支持头条、B站等平台'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showPasteLinkDialog(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importLocalVideo(BuildContext context) async {
    try {
      final video = await ref.read(videoRepositoryProvider).importVideo();
      if (video == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未选择视频')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  Future<void> _showPasteLinkDialog(BuildContext context) async {
    final controller = TextEditingController();

    try {
      final clipData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipData?.text != null && clipData!.text!.contains('http')) {
        controller.text = clipData.text!;
      }
    } catch (_) {}

    if (!context.mounted) return;

    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('粘贴视频链接'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '粘贴分享文本或视频链接...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('开始导入'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (text == null || text.trim().isEmpty || !context.mounted) return;

    _startUrlImport(context, text.trim());
  }

  void _startUrlImport(BuildContext context, String text) {
    final stateNotifier = ValueNotifier<ImportState>(
      const ImportState(ImportStep.extracting, '准备中...'),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ImportProgressDialog(
        state: stateNotifier,
        onCancel: () => Navigator.pop(ctx),
      ),
    );

    ref.read(videoImportServiceProvider).importFromText(text, stateNotifier).then((_) {
      if (context.mounted &&
          stateNotifier.value.step == ImportStep.done) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('视频导入成功')),
        );
      }
    });
  }
}

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback onImport;

  const _Header({required this.count, required this.onImport});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '视频库',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '共 $count 个视频',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onImport,
                borderRadius: BorderRadius.circular(14),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends ConsumerWidget {
  final VideoEntry video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/player/${video.id}'),
      onLongPress: () => _showDeleteDialog(context, ref),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            video.thumbnailPath != null
                ? Image.file(
                    File(video.thumbnailPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (video.subtitlePath != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.subtitles_outlined,
                          size: 12, color: Colors.white70),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceMuted,
        child: const Center(
          child: Icon(Icons.movie_outlined, size: 40, color: AppColors.textTertiary),
        ),
      );

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除视频'),
        content: Text('确定删除"${video.title}"？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(videoRepositoryProvider).deleteVideo(video.id);
              Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _ImportProgressDialog extends StatelessWidget {
  final ValueNotifier<ImportState> state;
  final VoidCallback onCancel;

  const _ImportProgressDialog({required this.state, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ImportState>(
      valueListenable: state,
      builder: (context, importState, _) {
        final steps = [
          _StepInfo('解析链接', ImportStep.extracting),
          _StepInfo('下载视频', ImportStep.downloading),
          _StepInfo('生成字幕', ImportStep.subtitling),
          _StepInfo('导入完成', ImportStep.importing),
        ];

        return AlertDialog(
          title: const Text('导入视频'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (importState.step == ImportStep.error) ...[
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(importState.message,
                        style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ] else ...[
                for (final step in steps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        _buildStepIcon(step.step, importState.step),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isCurrentStep(step.step, importState.step)
                                ? importState.message
                                : step.label,
                            style: TextStyle(
                              color: _isPastStep(step.step, importState.step)
                                  ? Colors.green
                                  : _isCurrentStep(step.step, importState.step)
                                      ? null
                                      : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
          actions: [
            if (importState.step == ImportStep.error)
              FilledButton(onPressed: onCancel, child: const Text('关闭'))
            else if (importState.step != ImportStep.done)
              TextButton(onPressed: onCancel, child: const Text('取消')),
          ],
        );
      },
    );
  }

  Widget _buildStepIcon(ImportStep step, ImportStep current) {
    if (_isPastStep(step, current)) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    }
    if (_isCurrentStep(step, current)) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20);
  }

  bool _isPastStep(ImportStep step, ImportStep current) {
    return step.index < current.index;
  }

  bool _isCurrentStep(ImportStep step, ImportStep current) {
    return step.index == current.index;
  }
}

class _StepInfo {
  final String label;
  final ImportStep step;
  const _StepInfo(this.label, this.step);
}
