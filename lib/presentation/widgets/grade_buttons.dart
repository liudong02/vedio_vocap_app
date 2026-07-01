import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GradeButtons extends StatelessWidget {
  final void Function(int grade) onGrade;
  const GradeButtons({super.key, required this.onGrade});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GradeBtn(
            label: '忘记',
            sublabel: '重来',
            color: AppColors.gradeAgain,
            onTap: () => onGrade(0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GradeBtn(
            label: '模糊',
            sublabel: '加强',
            color: AppColors.gradeHard,
            onTap: () => onGrade(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GradeBtn(
            label: '记得',
            sublabel: '稍难',
            color: AppColors.gradeGood,
            onTap: () => onGrade(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GradeBtn(
            label: '简单',
            sublabel: '轻松',
            color: AppColors.gradeEasy,
            onTap: () => onGrade(5),
          ),
        ),
      ],
    );
  }
}

class GradeBtn extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const GradeBtn({
    super.key,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(76)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(sublabel,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: color.withAlpha(180))),
          ],
        ),
      ),
    );
  }
}
