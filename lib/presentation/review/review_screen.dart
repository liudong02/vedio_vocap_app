import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/models/word_definition.dart';
import '../../data/repositories/word_repository.dart';
import '../widgets/grade_buttons.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_icon.dart';
import '../widgets/soft_card.dart';

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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Progress bar
              if (!_sessionDone && !_loading && _dueCards.isNotEmpty)
                _buildProgressBar(),

              // Body
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _sessionDone
                        ? _DoneView(
                            reviewedCount: _dueCards.length,
                            onReload: () {
                              setState(() {
                                _currentIndex = 0;
                                _revealed = false;
                                _loading = true;
                                _sessionDone = false;
                              });
                              _loadDueCards();
                            },
                          )
                        : _FlashCard(
                            card: _currentCard,
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
          Text('今日复习', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          if (!_sessionDone && !_loading && _dueCards.isNotEmpty)
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
    final progress = (_currentIndex) / _dueCards.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    required this.widthFactor,
    required this.child,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SoftCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Screenshot
                  if (card.screenshotPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(card.screenshotPath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  const SizedBox(height: 16),

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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Word
                  GradientText(
                    text: card.word,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (card.phonetic != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(card.phonetic!,
                          style: const TextStyle(
                              color: AppColors.textTertiary, fontSize: 14)),
                    ),
                  const SizedBox(height: 20),

                  // Revealed definitions
                  if (revealed && def != null)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          if (def.chineseTranslation != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                def.chineseTranslation!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                          for (final meaning in def.meanings) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  Chip(label: Text(meaning.partOfSpeech)),
                            ),
                            for (final d in meaning.definitions)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 6, left: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '• ${d.definition}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Action buttons
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

class _DoneView extends StatelessWidget {
  final int reviewedCount;
  final VoidCallback onReload;
  const _DoneView({required this.reviewedCount, required this.onReload});

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
            Text(
              '太棒了!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '今日复习已完成',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '已复习 $reviewedCount 个单词',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('刷新'),
            ),
          ],
        ),
      ),
    );
  }
}
