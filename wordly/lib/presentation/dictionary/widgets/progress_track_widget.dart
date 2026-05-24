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
          // ── Header ──────────────────────────────────
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

          // ── Dots track ──────────────────────────────
          _DotsTrack(currentStage: stage, totalStages: labels.length),
          const SizedBox(height: 12),

          // ── Stage labels ────────────────────────────
          _StageLabels(labels: labels, currentStage: stage),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Checkbox row ─────────────────────────────
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

// ─── Review Checkbox ───────────────────────────────────────────

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
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween:
            Tween(begin: 1.0, end: 0.8).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              _runAnimation();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _runAnimation() {
    _controller.forward().then((_) {
      _controller.reset();
      widget.onMarkAllReviewed();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Всё завершено
    if (widget.isAllCompleted) {
      return Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Text(
            'All words completed',
            style: AppTextStyles.caption.copyWith(color: AppColors.success),
          ),
        ],
      );
    }

    // Ещё не время
    if (!widget.isDue) {
      return const Row(
        children: [
          Icon(Icons.schedule, size: 16, color: AppColors.textHint),
          SizedBox(width: 10),
          Text('Not yet time to review', style: AppTextStyles.caption),
        ],
      );
    }

    // Пора повторять
    return InkWell(
      onTap: () => _confirm(context),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            // Просто scale на чекбоксе — никаких switcher
            ScaleTransition(
              scale: _scaleAnim,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: false,
                  onChanged: (_) => _confirm(context),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mark all as reviewed',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${widget.wordCount} words ready for review',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dots Track ────────────────────────────────────────────────

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

        return _Dot(isPassed: isPassed, isCurrent: isCurrent);
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isPassed;
  final bool isCurrent;

  const _Dot({required this.isPassed, required this.isCurrent});

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
          border: Border.all(color: AppColors.primaryLight, width: 3),
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

// ─── Stage Labels ──────────────────────────────────────────────

class _StageLabels extends StatelessWidget {
  final List<String> labels;
  final int currentStage;

  const _StageLabels({required this.labels, required this.currentStage});

  @override
  Widget build(BuildContext context) {
    final current = labels[currentStage];
    final hasNext = currentStage < labels.length - 1;
    final next = hasNext ? labels[currentStage + 1] : null;

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
            style: AppTextStyles.caption.copyWith(color: AppColors.success),
          ),
      ],
    );
  }
}
