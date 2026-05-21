import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/models/word_definition.dart';
import '../../data/repositories/word_repository.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  List<WordCardEntry> _dueCards = [];
  int _currentIndex = 0;
  bool _revealed = false;
  bool _loading = true;
  bool _sessionDone = false;

  @override
  void initState() {
    super.initState();
    _loadDueCards();
  }

  Future<void> _loadDueCards() async {
    final cards = await ref.read(wordRepositoryProvider).getDueCards();
    setState(() {
      _dueCards = cards;
      _loading = false;
      _sessionDone = cards.isEmpty;
    });
  }

  WordCardEntry get _currentCard => _dueCards[_currentIndex];

  void _reveal() => setState(() => _revealed = true);

  Future<void> _grade(int grade) async {
    await ref.read(wordRepositoryProvider).recordReview(
          card: _currentCard,
          grade: grade,
        );

    final isLast = _currentIndex >= _dueCards.length - 1;
    setState(() {
      if (isLast) {
        _sessionDone = true;
      } else {
        _currentIndex++;
        _revealed = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日复习'),
        actions: [
          if (!_sessionDone && !_loading && _dueCards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${_dueCards.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessionDone
              ? _DoneView(onReload: () {
                  setState(() {
                    _currentIndex = 0;
                    _revealed = false;
                    _loading = true;
                    _sessionDone = false;
                  });
                  _loadDueCards();
                })
              : _FlashCard(
                  card: _currentCard,
                  revealed: _revealed,
                  onReveal: _reveal,
                  onGrade: _grade,
                ),
    );
  }
}

class _FlashCard extends StatelessWidget {
  final WordCardEntry card;
  final bool revealed;
  final VoidCallback onReveal;
  final void Function(int grade) onGrade;

  const _FlashCard({
    required this.card,
    required this.revealed,
    required this.onReveal,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    WordDefinition? def;
    try {
      def = WordDefinition.fromStoredJson(
        jsonDecode(card.definitionJson) as Map<String, dynamic>,
      );
    } catch (_) {}

    return Column(
      children: [
        // Progress indicator
        const LinearProgressIndicator(
          value: null,
          backgroundColor: Colors.transparent,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Screenshot
                if (card.screenshotPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(card.screenshotPath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: 16),

                // Context (always shown)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '"${card.context}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 20),

                // Word (always shown)
                Text(
                  card.word,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (card.phonetic != null)
                  Text(card.phonetic!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 24),

                // Revealed: show definition
                if (revealed && def != null) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  for (final meaning in def.meanings) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text(meaning.partOfSpeech),
                        padding: EdgeInsets.zero,
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                    ),
                    for (final d in meaning.definitions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('• ${d.definition}'),
                        ),
                      ),
                  ],
                ],

                if (!revealed)
                  const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: revealed
              ? _GradeButtons(onGrade: onGrade)
              : SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onReveal,
                    child: const Text('显示答案'),
                  ),
                ),
        ),
      ],
    );
  }
}

class _GradeButtons extends StatelessWidget {
  final void Function(int grade) onGrade;
  const _GradeButtons({required this.onGrade});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GradeBtn(
            label: '完全忘记',
            sublabel: '明天再来',
            color: Colors.red,
            onTap: () => onGrade(0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _GradeBtn(
            label: '有点印象',
            sublabel: '需要加强',
            color: Colors.orange,
            onTap: () => onGrade(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _GradeBtn(
            label: '记得',
            sublabel: '稍有困难',
            color: Colors.blue,
            onTap: () => onGrade(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _GradeBtn(
            label: '完全记得',
            sublabel: '轻松回忆',
            color: Colors.green,
            onTap: () => onGrade(5),
          ),
        ),
      ],
    );
  }
}

class _GradeBtn extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _GradeBtn({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            Text(sublabel,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: color.withAlpha(180))),
          ],
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  final VoidCallback onReload;
  const _DoneView({required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            '今日复习完成！',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '继续积累，明天再来',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }
}
