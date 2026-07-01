import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../data/repositories/wordbank_repository.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_icon.dart';
import '../widgets/soft_card.dart';

class ChallengeDashboard extends ConsumerStatefulWidget {
  const ChallengeDashboard({super.key});

  @override
  ConsumerState<ChallengeDashboard> createState() => _ChallengeDashboardState();
}

class _ChallengeDashboardState extends ConsumerState<ChallengeDashboard> {
  bool _initializing = true;
  ChallengeStats? _stats;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final repo = ref.read(wordBankRepositoryProvider);
    await repo.initializeWordBank();
    await _refreshStats();
    if (mounted) setState(() => _initializing = false);
  }

  Future<void> _refreshStats() async {
    final stats = await ref.read(wordBankRepositoryProvider).getChallengeStats();
    if (mounted) setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: _initializing
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshStats,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _Header(streakDays: _stats?.streakDays ?? 0),
                    const SizedBox(height: 20),
                    _ProgressCard(stats: _stats!),
                    const SizedBox(height: 16),
                    _TodayStats(stats: _stats!),
                    const SizedBox(height: 20),
                    _ModeCards(
                      dueCount: _stats?.dueReviewCount ?? 0,
                      onScan: () async {
                        await context.push('/challenge/scan');
                        _refreshStats();
                      },
                      onReview: () async {
                        await context.push('/challenge/review');
                        _refreshStats();
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int streakDays;
  const _Header({required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('7000词挑战', style: Theme.of(context).textTheme.headlineMedium),
        const Spacer(),
        if (streakDays > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x1AFF9800),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x33FF9800)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department,
                    size: 16, color: Color(0xFFFF9800)),
                const SizedBox(width: 4),
                Text(
                  '连续$streakDays天',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ChallengeStats stats;
  const _ProgressCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final progress = stats.totalWords > 0
        ? stats.totalScanned / stats.totalWords
        : 0.0;

    return SoftCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _ProgressRingPainter(progress: progress),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GradientText(
                      text: '${stats.totalScanned}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '/ ${stats.totalWords}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _LevelBar(label: 'A1', color: const Color(0xFF4CAF50), total: 821, learned: _levelLearned(stats, 821)),
          const SizedBox(height: 8),
          _LevelBar(label: 'A2', color: const Color(0xFF8BC34A), total: 790, learned: _levelLearned(stats, 790, offset: 821)),
          const SizedBox(height: 8),
          _LevelBar(label: 'B1', color: const Color(0xFFFFC107), total: 726, learned: _levelLearned(stats, 726, offset: 1611)),
          const SizedBox(height: 8),
          _LevelBar(label: 'B2', color: const Color(0xFFFF9800), total: 1323, learned: _levelLearned(stats, 1323, offset: 2337)),
          const SizedBox(height: 8),
          _LevelBar(label: 'C1', color: const Color(0xFFE91E63), total: 1294, learned: _levelLearned(stats, 1294, offset: 3660)),
          const SizedBox(height: 8),
          _LevelBar(label: 'EXT', color: const Color(0xFF9C27B0), total: 2046, learned: _levelLearned(stats, 2046, offset: 4954)),
        ],
      ),
    );
  }

  int _levelLearned(ChallengeStats stats, int levelTotal, {int offset = 0}) {
    final scanned = stats.totalScanned;
    if (scanned <= offset) return 0;
    return math.min(scanned - offset, levelTotal);
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  _ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = AppColors.surfaceMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      const gradient = SweepGradient(
        startAngle: -1.5707963267948966,
        endAngle: 4.71238898038469,
        colors: [AppColors.primaryBlue, AppColors.primaryPurple],
      );

      final fgPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.progress != progress;
}

class _LevelBar extends StatelessWidget {
  final String label;
  final Color color;
  final int total;
  final int learned;
  const _LevelBar({
    required this.label,
    required this.color,
    required this.total,
    required this.learned,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (learned / total).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            '$learned/$total',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayStats extends StatelessWidget {
  final ChallengeStats stats;
  const _TodayStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SoftCard(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                const GradientIcon(icon: Icons.bolt_rounded, size: 24),
                const SizedBox(height: 8),
                Text(
                  '${stats.todayLearned}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  '今日学习',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SoftCard(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                const GradientIcon(icon: Icons.emoji_events_rounded, size: 24),
                const SizedBox(height: 8),
                Text(
                  '${stats.totalMastered}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  '已掌握',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeCards extends StatelessWidget {
  final int dueCount;
  final VoidCallback onScan;
  final VoidCallback onReview;
  const _ModeCards({
    required this.dueCount,
    required this.onScan,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            label: '快速刷词',
            icon: Icons.speed_rounded,
            height: 56,
            onPressed: onScan,
          ),
        ),
        const SizedBox(height: 12),
        SoftCard(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          onTap: dueCount > 0 ? onReview : null,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: dueCount > 0
                      ? const Color(0x1AFF9800)
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: dueCount > 0
                      ? const Color(0xFFFF9800)
                      : AppColors.textTertiary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '待复习',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      dueCount > 0 ? '$dueCount个词需要复习' : '暂无待复习单词',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (dueCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFF9800),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$dueCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
