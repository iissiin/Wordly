import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordly/domain/entities/quiz_settings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../domain/entities/dictionary.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';

class FlashCardScreen extends StatefulWidget {
  final Dictionary dictionary;
  final QuizSettings settings;

  const FlashCardScreen({
    super.key,
    required this.dictionary,
    required this.settings,
  });

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizCubit>().startQuiz(widget.dictionary, widget.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionary.name),
        actions: [
          TextButton(
            onPressed: () => _confirmExit(context),
            child: const Text(
              'End',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: BlocConsumer<QuizCubit, QuizState>(
        listener: (context, state) {
          if (state is QuizCompleted) {
            context.pushReplacement(
              '/dictionary/${widget.dictionary.id}/result',
              extra: {
                'correct': state.correctCount,
                'total': state.totalWords,
              },
            );
          }
        },
        builder: (context, state) {
          if (state is QuizInProgress) {
            return _FlashCardBody(state: state);
          }
          if (state is QuizError) {
            return Center(
              child: Text(state.message, style: AppTextStyles.caption),
            );
          }
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End session?'),
        content: const Text('Your progress for this session will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }
}

// ─── FlashCard Body ────────────────────────────────────────────

class _FlashCardBody extends StatelessWidget {
  final QuizInProgress state;

  const _FlashCardBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Progress bar ──────────────────────────
            _ProgressBar(
              current: state.currentIndex,
              total: state.totalWords,
            ),
            const SizedBox(height: 8),

            Text(
              '${state.currentIndex + 1} / ${state.totalWords}',
              style: AppTextStyles.small,
            ),

            const SizedBox(height: 32),

            // ── Card ──────────────────────────────────
            Expanded(
              child: _Card(state: state),
            ),

            const SizedBox(height: 24),

            // ── Buttons ───────────────────────────────
            if (!state.isAnswerRevealed)
              AppButton(
                label: 'Show answer',
                variant: AppButtonVariant.secondary,
                width: double.infinity,
                onPressed: () => context.read<QuizCubit>().revealAnswer(),
              )
            else
              const _AnswerButtons(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Card Widget ───────────────────────────────────────────────

class _Card extends StatelessWidget {
  final QuizInProgress state;

  const _Card({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Question ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              context.read<QuizCubit>().questionFor(state.currentWord),
              style: AppTextStyles.heading1.copyWith(fontSize: 28),
              textAlign: TextAlign.center,
            ),
          ),

          if (state.isAnswerRevealed) ...[
            const SizedBox(height: 32),
            Container(
              width: 40,
              height: 1,
              color: AppColors.border,
            ),
            const SizedBox(height: 32),

            // ── Answer ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.currentWord.translation,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            const Text(
              'tap to reveal',
              style: AppTextStyles.small,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Answer Buttons ────────────────────────────────────────────

class _AnswerButtons extends StatelessWidget {
  const _AnswerButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.read<QuizCubit>().markIncorrect(),
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.error,
            ),
            label: const Text(
              "Don't know",
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.read<QuizCubit>().markCorrect(),
            icon: const Icon(
              Icons.check,
              size: 18,
              color: AppColors.success,
            ),
            label: const Text(
              'I know',
              style: TextStyle(color: AppColors.success),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              side: const BorderSide(color: AppColors.success),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Progress Bar ──────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppColors.border,
        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        minHeight: 3,
      ),
    );
  }
}
