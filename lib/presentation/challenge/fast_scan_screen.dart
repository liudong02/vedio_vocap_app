import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/wordbank_repository.dart';
import '../widgets/gradient_icon.dart';
import '../widgets/phonetic_button.dart';
import '../widgets/soft_card.dart';

class FastScanScreen extends ConsumerStatefulWidget {
  const FastScanScreen({super.key});

  @override
  ConsumerState<FastScanScreen> createState() => _FastScanScreenState();
}

class _FastScanScreenState extends ConsumerState<FastScanScreen> {
  static const _batchSize = 100;
  List<WordBankEntry> _batch = [];
  List<WordBankWord?> _wordData = [];
  int _current = 0;
  bool _loading = true;
  bool _done = false;
  int _knownCount = 0;
  int _unknownCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBatch();
  }

  Future<void> _loadBatch() async {
    final repo = ref.read(wordBankRepositoryProvider);
    final batch = await repo.getNextScanBatch(_batchSize);
    if (batch.isEmpty) {
      setState(() {
        _loading = false;
        _done = true;
      });
      return;
    }
    final data = await repo.getWordDataBatch(
      batch.map((e) => e.wordIndex).toList(),
    );
    final dataMap = {for (final w in data) w.index: w};
    setState(() {
      _batch = batch;
      _wordData = batch.map((e) => dataMap[e.wordIndex]).toList();
      _current = 0;
      _knownCount = 0;
      _unknownCount = 0;
      _loading = false;
      _done = false;
    });
  }

  Future<void> _answer(bool known) async {
    final entry = _batch[_current];
    await ref.read(wordBankRepositoryProvider).recordScanResult(
          entry.wordIndex,
          known,
        );
    if (known) {
      _knownCount++;
    } else {
      _unknownCount++;
    }

    if (_current >= _batch.length - 1) {
      setState(() => _done = true);
    } else {
      setState(() => _current++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _done
                  ? _ScanSummary(
                      known: _knownCount,
                      unknown: _unknownCount,
                      onBack: () => Navigator.pop(context),
                    )
                  : _ScanBody(
                      current: _current,
                      total: _batch.length,
                      wordData: _wordData[_current],
                      entry: _batch[_current],
                      onKnown: () => _answer(true),
                      onUnknown: () => _answer(false),
                      onBack: () => Navigator.pop(context),
                    ),
        ),
      ),
    );
  }
}

class _ScanBody extends StatelessWidget {
  final int current;
  final int total;
  final WordBankWord? wordData;
  final WordBankEntry entry;
  final VoidCallback onKnown;
  final VoidCallback onUnknown;
  final VoidCallback onBack;

  const _ScanBody({
    required this.current,
    required this.total,
    required this.wordData,
    required this.entry,
    required this.onKnown,
    required this.onUnknown,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final word = wordData?.word ?? entry.word;
    final phonetic = wordData?.phonetic ?? '';
    final audioUrl = wordData?.audioUrl ?? '';
    final translation = wordData?.translation ?? '';
    final examples = wordData?.examples ?? [];
    final level = entry.level;
    final progress = total > 0 ? (current / total) : 0.0;

    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: onBack,
              ),
              const SizedBox(width: 8),
              Text(
                '${current + 1} / $total',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _levelColor(level).withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _levelColor(level),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        ),

        // Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SoftCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientText(
                    text: word,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (phonetic.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    PhoneticButton(phonetic: phonetic, audioUrl: audioUrl),
                  ],
                  const SizedBox(height: 20),
                  if (translation.isNotEmpty)
                    Text(
                      translation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  if (examples.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x0D7B61FF),
                        border: Border.all(color: const Color(0x1A7B61FF)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        examples.first,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: _ScanButton(
                  label: '不认识',
                  color: const Color(0xFFEE9B3B),
                  icon: Icons.close_rounded,
                  onTap: onUnknown,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ScanButton(
                  label: '认识',
                  color: const Color(0xFF4FBF7B),
                  icon: Icons.check_rounded,
                  onTap: onKnown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _levelColor(String level) {
    return switch (level) {
      'A1' => const Color(0xFF4CAF50),
      'A2' => const Color(0xFF8BC34A),
      'B1' => const Color(0xFFFFC107),
      'B2' => const Color(0xFFFF9800),
      'C1' => const Color(0xFFE91E63),
      'EXT' => const Color(0xFF9C27B0),
      _ => AppColors.textTertiary,
    };
  }
}

class _ScanButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ScanButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(76), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanSummary extends StatelessWidget {
  final int known;
  final int unknown;
  final VoidCallback onBack;

  const _ScanSummary({
    required this.known,
    required this.unknown,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final total = known + unknown;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GradientIcon(icon: Icons.celebration_rounded, size: 80),
            const SizedBox(height: 24),
            Text('本轮完成!',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '共学习 $total 个单词',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(
                  label: '认识',
                  count: known,
                  color: const Color(0xFF4FBF7B),
                ),
                const SizedBox(width: 16),
                _StatChip(
                  label: '不认识',
                  count: unknown,
                  color: const Color(0xFFEE9B3B),
                ),
              ],
            ),
            const SizedBox(height: 32),
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

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withAlpha(180)),
          ),
        ],
      ),
    );
  }
}
