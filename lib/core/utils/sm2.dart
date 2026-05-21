class SM2Result {
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReview;

  const SM2Result({
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReview,
  });
}

class SM2 {
  /// [grade] 0-5: 0=完全忘记, 3=记得（艰难）, 5=完全记得
  static SM2Result calculate({
    required double easeFactor,
    required int interval,
    required int repetitions,
    required int grade,
  }) {
    if (grade < 3) {
      return SM2Result(
        easeFactor: easeFactor,
        interval: 1,
        repetitions: 0,
        nextReview: DateTime.now().add(const Duration(days: 1)),
      );
    }

    final newInterval = switch (repetitions) {
      0 => 1,
      1 => 6,
      _ => (interval * easeFactor).round(),
    };

    final newEF = (easeFactor + 0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02))
        .clamp(1.3, 2.5);

    return SM2Result(
      easeFactor: newEF,
      interval: newInterval,
      repetitions: repetitions + 1,
      nextReview: DateTime.now().add(Duration(days: newInterval)),
    );
  }
}
