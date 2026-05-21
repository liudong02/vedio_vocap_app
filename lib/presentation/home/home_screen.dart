import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/database/app_database.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosStream = ref.watch(videoRepositoryProvider).watchAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoVocab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '导入视频',
            onPressed: () => _importVideo(context, ref),
          ),
        ],
      ),
      body: StreamBuilder<List<VideoEntry>>(
        stream: videosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final videos = snapshot.data ?? [];
          if (videos.isEmpty) {
            return _EmptyState(onImport: () => _importVideo(context, ref));
          }
          return _VideoGrid(videos: videos);
        },
      ),
    );
  }

  Future<void> _importVideo(BuildContext context, WidgetRef ref) async {
    final video = await ref.read(videoRepositoryProvider).importVideo();
    if (video == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未选择视频')),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onImport;
  const _EmptyState({required this.onImport});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '还没有视频',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.add),
            label: const Text('导入视频'),
          ),
        ],
      ),
    );
  }
}

class _VideoGrid extends ConsumerWidget {
  final List<VideoEntry> videos;
  const _VideoGrid({required this.videos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 11,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: videos.length,
      itemBuilder: (context, i) => _VideoCard(video: videos[i]),
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
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            video.thumbnailPath != null
                ? Image.file(
                    File(video.thumbnailPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),

            // Gradient + title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Subtitle indicator
            if (video.subtitlePath != null)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.subtitles, color: Colors.white70, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.movie, size: 40, color: Colors.grey),
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
