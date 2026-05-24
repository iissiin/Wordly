import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class QuizResultScreen extends StatelessWidget {
  final int correct;
  final int total;

  const QuizResultScreen({
    super.key,
    required this.correct,
    required this.total,
  });

  double get _ratio => total == 0 ? 0 : correct / total;

  String get _resultLabel {
    if (_ratio == 1.0) return 'Perfect';
    if (_ratio >= 0.8) return 'Good job';
    if (_ratio >= 0.5) return 'Keep going';
    return 'Keep practicing';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(AppStrings.quizComplete),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Result label ──────────────────────────
              Text(
                _resultLabel,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),

              // ── Score ─────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: '$correct',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    TextSpan(
                      text: '/$total',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: 36,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              // ignore: prefer_const_constructors
              Text(
                'correct answers',
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: 40),

              // ── Score breakdown ───────────────────────
              _ScoreBar(correct: correct, total: total),

              const Spacer(flex: 3),

              // ── Actions ───────────────────────────────
              AppButton(
                label: AppStrings.done,
                width: double.infinity,
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: AppStrings.tryAgain,
                variant: AppButtonVariant.secondary,
                width: double.infinity,
                onPressed: () => context.pop(),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Score Bar ─────────────────────────────────────────────────

class _ScoreBar extends StatelessWidget {
  final int correct;
  final int total;

  const _ScoreBar({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final incorrect = total - correct;
    final ratio = total == 0 ? 0.0 : correct / total;

    return Column(
      children: [
        // ── Визуальная полоса ─────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (correct > 0)
                  Expanded(
                    flex: correct,
                    child: Container(color: AppColors.success),
                  ),
                if (incorrect > 0)
                  Expanded(
                    flex: incorrect,
                    child: Container(color: AppColors.border),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Легенда ───────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LegendItem(
              color: AppColors.success,
              label: 'Correct',
              count: correct,
            ),
            Text(
              '${(ratio * 100).round()}%',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            _LegendItem(
              color: AppColors.border,
              label: 'Incorrect',
              count: incorrect,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$count', style: AppTextStyles.bodyMedium),
            Text(label, style: AppTextStyles.small),
          ],
        ),
      ],
    );
  }
}
