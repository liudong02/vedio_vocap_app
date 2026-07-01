import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/wordbank_repository.dart';
import '../widgets/grade_buttons.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_icon.dart';
import '../widgets/phonetic_button.dart';
import '../widgets/soft_card.dart';

class WordBankReviewScreen extends ConsumerStatefulWidget {
  const WordBankReviewScreen({super.key});

  @override
  ConsumerState<WordBankReviewScreen> createState() =>
      _WordBankReviewScreenState();
}

class _WordBankReviewScreenState extends ConsumerState<WordBankReviewScreen> {
  List<WordBankEntry> _dueCards = [];
  List<WordBankWord?> _wordData = [];
  int _currentIndex = 0;
  bool _revealed = false;
  bool _loading = true;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _loadDue();
  }

  Future<void> _loadDue() async {
    final repo = ref.read(wordBankRepositoryProvider);
    final cards = await repo.getDueReviews();
    if (cards.isEmpty) {
      setState(() {
        _loading = false;
        _done = true;
      });
      return;
    }
    final data = await repo.getWordDataBatch(
      cards.map((e) => e.wordIndex).toList(),
    );
    final dataMap = {for (final w in data) w.index: w};
    setState(() {
      _dueCards = cards;
      _wordData = cards.map((e) => dataMap[e.wordIndex]).toList();
      _currentIndex = 0;
      _revealed = false;
      _loading = false;
      _done = false;
    });
  }

  void _reveal() => setState(() => _revealed = true);

  Future<void> _grade(int grade) async {
    final entry = _dueCards[_currentIndex];
    await ref.read(wordBankRepositoryProvider).recordReview(entry, grade);

    if (_currentIndex >= _dueCards.length - 1) {
      setState(() => _done = true);
    } else {
      setState(() {
        _currentIndex++;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              if (!_done && !_loading && _dueCards.isNotEmpty)
                _buildProgressBar(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _done
                        ? _ReviewDoneView(
                            count: _dueCards.length,
                            onBack: () => Navigator.pop(context),
                          )
                        : _ReviewCard(
                            entry: _dueCards[_currentIndex],
                            wordData: _wordData[_currentIndex],
                            revealed: _revealed,
                            onReveal: _reveal,
                            onGrade: _grade,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Text('词库复习', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          if (!_done && !_loading && _dueCards.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1} / ${_dueCards.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _dueCards.isNotEmpty
        ? (_currentIndex / _dueCards.length)
        : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 3,
          backgroundColor: AppColors.surfaceMuted,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final WordBankEntry entry;
  final WordBankWord? wordData;
  final bool revealed;
  final VoidCallback onReveal;
  final void Function(int grade) onGrade;

  const _ReviewCard({
    required this.entry,
    required this.wordData,
    required this.revealed,
    required this.onReveal,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    final word = wordData?.word ?? entry.word;
    final phonetic = wordData?.phonetic ?? '';
    final audioUrl = wordData?.audioUrl ?? '';
    final translation = wordData?.translation ?? '';
    final examples = wordData?.examples ?? [];
    final level = entry.level;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SoftCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      level,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GradientText(
                    text: word,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (phonetic.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: PhoneticButton(phonetic: phonetic, audioUrl: audioUrl),
                    ),
                  const SizedBox(height: 20),
                  if (revealed) ...[
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    if (translation.isNotEmpty)
                      Text(
                        translation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                          height: 1.5,
                        ),
                      ),
                    if (examples.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      for (final ex in examples)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0x0D7B61FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              ex,
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: revealed
              ? GradeButtons(onGrade: onGrade)
              : SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: '显示答案',
                    height: 56,
                    onPressed: onReveal,
                  ),
                ),
        ),
      ],
    );
  }
}

class _ReviewDoneView extends StatelessWidget {
  final int count;
  final VoidCallback onBack;
  const _ReviewDoneView({required this.count, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GradientIcon(icon: Icons.celebration_rounded, size: 80),
            const SizedBox(height: 24),
            Text('复习完成!',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '已复习 $count 个单词',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 160,
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('返回'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
