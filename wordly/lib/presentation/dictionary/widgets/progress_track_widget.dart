import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/spaced_repetition.dart';
import '../../../domain/entities/word.dart';

class ProgressTrackWidget extends StatelessWidget {
  final List<Word> words;
  final String dictionaryId;
  final VoidCallback onMarkAllReviewed;

  const ProgressTrackWidget({
    super.key,
    required this.words,
    required this.dictionaryId,
    required this.onMarkAllReviewed,
  });

  int get _averageStage {
    if (words.isEmpty) return 0;
    final total = words.fold(0, (sum, w) => sum + w.repetitionStage);
    return (total / words.length).round().clamp(0, SpacedRepetition.maxStage);
  }

  bool get _isDue {
    if (words.isEmpty) return false;
    final dueCount =
        words.where((w) => w.isDueForReview && !w.isCompleted).length;
    return dueCount >= (words.length / 2).ceil();
  }

  bool get _isAllCompleted {
    return words.isNotEmpty && words.every((w) => w.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final stage = _averageStage;
    const labels = SpacedRepetition.stageLabels;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: _isDue ? AppColors.primary : AppColors.border,
          width: _isDue ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Review progress', style: AppTextStyles.caption),
              Text(
                'Stage ${stage + 1} of ${SpacedRepetition.maxStage + 1}',
                style: AppTextStyles.small,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DotsTrack(
            currentStage: stage,
            totalStages: labels.length,
          ),
          const SizedBox(height: 12),
          _StageLabels(
            labels: labels,
            currentStage: stage,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _ReviewCheckbox(
            isDue: _isDue,
            isAllCompleted: _isAllCompleted,
            wordCount: words.length,
            onMarkAllReviewed: onMarkAllReviewed,
          ),
        ],
      ),
    );
  }
}

// ─── Review Checkbox (CLEAN VERSION) ───────────────────────────

class _ReviewCheckbox extends StatefulWidget {
  final bool isDue;
  final bool isAllCompleted;
  final int wordCount;
  final VoidCallback onMarkAllReviewed;

  const _ReviewCheckbox({
    required this.isDue,
    required this.isAllCompleted,
    required this.wordCount,
    required this.onMarkAllReviewed,
  });

  @override
  State<_ReviewCheckbox> createState() => _ReviewCheckboxState();
}

class _ReviewCheckboxState extends State<_ReviewCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  bool _checked = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handle() async {
    setState(() => _checked = true);

    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 120));

    widget.onMarkAllReviewed();

    if (!mounted) return;

    _controller.reset();

    setState(() => _checked = false);
  }

  void _confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark as reviewed?'),
        content: const Text(
          'This will move all words to the next review stage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handle();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAllCompleted) {
      return Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Text(
            'All words completed',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      );
    }

    if (!widget.isDue) {
      return const Row(
        children: [
          Icon(Icons.schedule, size: 16, color: AppColors.textHint),
          SizedBox(width: 10),
          Text(
            'Not yet time to review',
            style: AppTextStyles.caption,
          ),
        ],
      );
    }

    return InkWell(
      onTap: () => _confirm(context),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: _checked
              ? AppColors.primary.withOpacity(0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ScaleTransition(
              scale: _scale,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _checked,
                  onChanged: (_) => _confirm(context),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _checked ? 0.7 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mark all as reviewed',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.wordCount} words ready for review',
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dots + Labels (без изменений) ─────────────────────────────

class _DotsTrack extends StatelessWidget {
  final int currentStage;
  final int totalStages;

  const _DotsTrack({
    required this.currentStage,
    required this.totalStages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalStages * 2 - 1, (index) {
        if (index.isOdd) {
          final stageIndex = index ~/ 2;
          final isPassed = stageIndex < currentStage;

          return Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: isPassed ? AppColors.primary : AppColors.border,
            ),
          );
        }

        final dotIndex = index ~/ 2;
        final isPassed = dotIndex < currentStage;
        final isCurrent = dotIndex == currentStage;

        return _Dot(
          isPassed: isPassed,
          isCurrent: isCurrent,
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isPassed;
  final bool isCurrent;

  const _Dot({
    required this.isPassed,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    if (isPassed) {
      return Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      );
    }

    if (isCurrent) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryLight,
            width: 3,
          ),
        ),
      );
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}

class _StageLabels extends StatelessWidget {
  final List<String> labels;
  final int currentStage;

  const _StageLabels({
    required this.labels,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    final current = labels[currentStage];
    final next =
        currentStage < labels.length - 1 ? labels[currentStage + 1] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current', style: AppTextStyles.small),
            Text(
              current,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (next != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Next review', style: AppTextStyles.small),
              Text(next, style: AppTextStyles.caption),
            ],
          )
        else
          Text(
            'Completed',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success,
            ),
          ),
      ],
    );
  }
}
