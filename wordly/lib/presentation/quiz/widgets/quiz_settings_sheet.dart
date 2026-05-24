import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/quiz_settings.dart';

class QuizSettingsSheet extends StatefulWidget {
  final QuizSettings initial;
  final String quizType; // 'flashcard' или 'written'

  const QuizSettingsSheet({
    super.key,
    required this.initial,
    required this.quizType,
  });

  @override
  State<QuizSettingsSheet> createState() => _QuizSettingsSheetState();
}

class _QuizSettingsSheetState extends State<QuizSettingsSheet> {
  late QuizSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ────────────────────────────────
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.quizType == 'flashcard' ? 'Flash Cards' : 'Written Input',
              style: AppTextStyles.heading3,
            ),
          ),

          const Divider(),
          const SizedBox(height: 8),

          // ── Translation direction ──────────────────
          const Text('Translation direction', style: AppTextStyles.caption),
          const SizedBox(height: 12),

          _DirectionSelector(
            value: _settings.direction,
            onChanged: (d) => setState(
              () => _settings = _settings.copyWith(direction: d),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),

          // ── Random order ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Random order', style: AppTextStyles.bodyMedium),
                  SizedBox(height: 2),
                  Text(
                    'Shuffle words before starting',
                    style: AppTextStyles.small,
                  ),
                ],
              ),
              Switch(
                value: _settings.randomOrder,
                onChanged: (v) => setState(
                  () => _settings = _settings.copyWith(randomOrder: v),
                ),
                activeColor: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Start button ───────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _settings),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Direction Selector ────────────────────────────────────────

class _DirectionSelector extends StatelessWidget {
  final TranslationDirection value;
  final ValueChanged<TranslationDirection> onChanged;

  const _DirectionSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DirectionOption(
          label: 'Word → Translation',
          icon: Icons.arrow_forward,
          isSelected: value == TranslationDirection.originalToTranslation,
          onTap: () => onChanged(TranslationDirection.originalToTranslation),
        ),
        const SizedBox(width: 10),
        _DirectionOption(
          label: 'Translation → Word',
          icon: Icons.arrow_back,
          isSelected: value == TranslationDirection.translationToOriginal,
          onTap: () => onChanged(TranslationDirection.translationToOriginal),
        ),
      ],
    );
  }
}

class _DirectionOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DirectionOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
