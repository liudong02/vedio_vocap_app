import 'package:flutter_test/flutter_test.dart';
import 'package:video_vocab/core/utils/sm2.dart';

void main() {
  group('SM2', () {
    const defaultEF = 2.5;

    test('first repetition gives interval=1', () {
      final result = SM2.calculate(
        easeFactor: defaultEF,
        interval: 0,
        repetitions: 0,
        grade: 5,
      );
      expect(result.interval, 1);
      expect(result.repetitions, 1);
    });

    test('second repetition gives interval=6', () {
      final result = SM2.calculate(
        easeFactor: defaultEF,
        interval: 1,
        repetitions: 1,
        grade: 5,
      );
      expect(result.interval, 6);
      expect(result.repetitions, 2);
    });

    test('third repetition multiplies by ease factor', () {
      final result = SM2.calculate(
        easeFactor: 2.5,
        interval: 6,
        repetitions: 2,
        grade: 5,
      );
      expect(result.interval, (6 * 2.5).round()); // 15
      expect(result.repetitions, 3);
    });

    test('grade < 3 resets to 1 day without changing ease factor', () {
      const ef = 2.3;
      final result = SM2.calculate(
        easeFactor: ef,
        interval: 15,
        repetitions: 3,
        grade: 2,
      );
      expect(result.interval, 1);
      expect(result.repetitions, 0);
      expect(result.easeFactor, ef); // unchanged on failure
    });

    test('ease factor decreases on grade=3', () {
      final result = SM2.calculate(
        easeFactor: 2.5,
        interval: 1,
        repetitions: 0,
        grade: 3,
      );
      // EF change: 0.1 - (5-3)*(0.08+(5-3)*0.02) = 0.1 - 2*(0.12) = -0.14
      expect(result.easeFactor, closeTo(2.36, 0.01));
    });

    test('ease factor clamps at 1.3 minimum', () {
      final result = SM2.calculate(
        easeFactor: 1.3,
        interval: 1,
        repetitions: 0,
        grade: 3,
      );
      expect(result.easeFactor, greaterThanOrEqualTo(1.3));
    });

    test('ease factor clamps at 2.5 maximum', () {
      final result = SM2.calculate(
        easeFactor: 2.5,
        interval: 1,
        repetitions: 0,
        grade: 5,
      );
      // Grade 5: EF change = 0.1 - 0*(0.08+0) = 0.1 → would be 2.6, clamped to 2.5
      expect(result.easeFactor, lessThanOrEqualTo(2.5));
    });

    test('nextReview is approximately interval days from now', () {
      final before = DateTime.now();
      final result = SM2.calculate(
        easeFactor: defaultEF,
        interval: 1,
        repetitions: 1,
        grade: 5,
      );
      final expectedDate = before.add(Duration(days: result.interval));
      final diff = result.nextReview.difference(expectedDate).inSeconds.abs();
      expect(diff, lessThan(5));
    });
  });
}
