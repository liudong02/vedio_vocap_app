import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/models/word_definition.dart';
import '../../data/repositories/word_repository.dart';
import '../widgets/bottom_sheet_handle.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/gradient_icon.dart';
import '../widgets/soft_card.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsStream = ref.watch(wordRepositoryProvider).watchAll();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<WordCardEntry>>(
          stream: wordsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final words = snapshot.data ?? [];
            if (words.isEmpty) {
              return const Column(
                children: [
                  _Header(count: 0),
                  Expanded(
                    child: EmptyStateView(
                      icon: Icons.menu_book_outlined,
                      title: '还没有收录的单词',
                      subtitle: '在视频中点击单词来收录',
                    ),
                  ),
                ],
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Header(count: words.length)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _WordCard(card: words[i]),
                      ),
                      childCount: words.length,
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
}

class _Header extends StatelessWidget {
  final int count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('单词本', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            '共 $count 个单词',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _WordCard extends ConsumerWidget {
  final WordCardEntry card;
  const _WordCard({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WordDefinition? def;
    try {
      def = WordDefinition.fromStoredJson(
        jsonDecode(card.definitionJson) as Map<String, dynamic>,
      );
    } catch (_) {}

    final firstDef = def?.meanings.firstOrNull?.definitions.firstOrNull;

    return SoftCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      onTap: () => _showDetail(context, card, def),
      onLongPress: () => _confirmDelete(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Thumbnail
              _ScreenshotThumb(path: card.screenshotPath),
              const SizedBox(width: 14),
              // Word info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.word,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (card.phonetic != null)
                      Text(
                        card.phonetic!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    if (firstDef != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          firstDef.definition,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary, size: 20),
            ],
          ),
          // Source video
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Icon(Icons.movie_outlined,
                    size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    card.videoTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除单词'),
        content: Text('确定删除"${card.word}"？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              ref.read(wordRepositoryProvider).deleteWord(card.id);
              Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showDetail(
      BuildContext context, WordCardEntry card, WordDefinition? def) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _WordDetailSheet(card: card, definition: def),
    );
  }
}

class _ScreenshotThumb extends StatelessWidget {
  final String? path;
  const _ScreenshotThumb({this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return Container(
        width: 64,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported_outlined,
            size: 20, color: AppColors.textTertiary),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path!),
        width: 64,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 64,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.broken_image_outlined,
              size: 20, color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

class _WordDetailSheet extends StatelessWidget {
  final WordCardEntry card;
  final WordDefinition? definition;

  const _WordDetailSheet({required this.card, required this.definition});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: ListView(
          controller: controller,
          children: [
            const BottomSheetHandle(),

            // Screenshot
            if (card.screenshotPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(card.screenshotPath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 16),

            // Word
            Text(card.word, style: Theme.of(context).textTheme.headlineMedium),
            if (card.phonetic != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(card.phonetic!,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 14)),
              ),

            // Chinese translation
            if (definition?.chineseTranslation != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: GradientText(
                  text: definition!.chineseTranslation!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 12),

            // Context
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x0D7B61FF),
                border: Border.all(color: const Color(0x1A7B61FF)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${card.context}"',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Source
            Row(
              children: [
                const Icon(Icons.movie_outlined,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '来自：${card.videoTitle}',
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 12),
                ),
              ],
            ),

            const Divider(height: 28),

            // Definitions
            if (definition != null)
              for (final meaning in definition!.meanings) ...[
                Chip(label: Text(meaning.partOfSpeech)),
                for (int i = 0; i < meaning.definitions.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ${meaning.definitions[i].definition}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        if (meaning.definitions[i].example != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              '例：${meaning.definitions[i].example}',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}
