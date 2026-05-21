import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/models/word_definition.dart';
import '../../data/repositories/word_repository.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsStream = ref.watch(wordRepositoryProvider).watchAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('单词本'),
      ),
      body: StreamBuilder<List<WordCardEntry>>(
        stream: wordsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final words = snapshot.data ?? [];
          if (words.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    '还没有收录的单词\n在视频中点击单词来收录',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: words.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => _WordTile(card: words[i]),
          );
        },
      ),
    );
  }
}

class _WordTile extends ConsumerWidget {
  final WordCardEntry card;
  const _WordTile({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WordDefinition? def;
    try {
      def = WordDefinition.fromStoredJson(
        jsonDecode(card.definitionJson) as Map<String, dynamic>,
      );
    } catch (_) {}

    final firstDef = def?.meanings.firstOrNull?.definitions.firstOrNull;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: _ScreenshotThumb(path: card.screenshotPath),
      title: Text(
        card.word,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.phonetic != null)
            Text(card.phonetic!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          if (firstDef != null)
            Text(
              firstDef.definition,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          Text(
            '来自：${card.videoTitle}',
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'delete') {
            _confirmDelete(context, ref);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'delete', child: Text('删除')),
        ],
      ),
      onTap: () => _showDetail(context, card, def),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除单词'),
        content: Text('确定删除"${card.word}"？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
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

  void _showDetail(BuildContext context, WordCardEntry card, WordDefinition? def) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
        width: 56,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.file(
        File(path!),
        width: 56,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 56,
          height: 42,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: ListView(
          controller: controller,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Screenshot
            if (card.screenshotPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(card.screenshotPath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 12),

            // Word
            Text(
              card.word,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (card.phonetic != null)
              Text(card.phonetic!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 8),

            // Context
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${card.context}"',
                style: TextStyle(
                    color: Colors.blueGrey[700], fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 8),
            Text('来自：${card.videoTitle}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const Divider(height: 24),

            // Definitions
            if (definition != null)
              for (final meaning in definition!.meanings) ...[
                Chip(
                  label: Text(meaning.partOfSpeech),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12),
                ),
                for (int i = 0; i < meaning.definitions.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${i + 1}. ${meaning.definitions[i].definition}'),
                        if (meaning.definitions[i].example != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2, left: 8),
                            child: Text(
                              '例：${meaning.definitions[i].example}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12,
                                  fontStyle: FontStyle.italic),
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
