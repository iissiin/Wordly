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

class WrittenScreen extends StatefulWidget {
  final Dictionary dictionary;
  final QuizSettings settings;

  const WrittenScreen({
    super.key,
    required this.dictionary,
    required this.settings,
  });

  @override
  State<WrittenScreen> createState() => _WrittenScreenState();
}

class _WrittenScreenState extends State<WrittenScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<QuizCubit>().startQuiz(widget.dictionary, widget.settings);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(QuizInProgress state) {
    if (_controller.text.trim().isEmpty) return;
    context.read<QuizCubit>().checkAnswer(_controller.text);
  }

  void _next() {
    _controller.clear();
    context.read<QuizCubit>().nextWord();
    // Фокус возвращаем после перехода к следующему слову
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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
            return _WrittenBody(
              state: state,
              controller: _controller,
              focusNode: _focusNode,
              onSubmit: () => _submit(state),
              onNext: _next,
            );
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
        content: const Text(
          'Your progress for this session will be lost.',
        ),
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

// ─── Written Body ──────────────────────────────────────────────

class _WrittenBody extends StatelessWidget {
  final QuizInProgress state;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final VoidCallback onNext;

  const _WrittenBody({
    required this.state,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isRevealed = state.isAnswerRevealed;
    final isCorrect = state.lastAnswerCorrect;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Progress ──────────────────────────────
            _ProgressBar(
              current: state.currentIndex,
              total: state.totalWords,
            ),
            const SizedBox(height: 8),
            Text(
              '${state.currentIndex + 1} / ${state.totalWords}',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: 40),

            // ── Word prompt ───────────────────────────
            const Text('Translate', style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Text(
              context.read<QuizCubit>().questionFor(state.currentWord),
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 32),

            // ── Input field ───────────────────────────
            _AnswerField(
              controller: controller,
              focusNode: focusNode,
              isRevealed: isRevealed,
              isCorrect: isCorrect,
              correctAnswer: state.currentWord.translation,
              onSubmit: onSubmit,
            ),

            const Spacer(),

            // ── Result feedback ───────────────────────
            if (isRevealed) ...[
              _ResultFeedback(
                isCorrect: isCorrect ?? false,
                correctAnswer: state.currentWord.translation,
              ),
              const SizedBox(height: 16),
            ],

            // ── Action button ─────────────────────────
            AppButton(
              label: isRevealed ? 'Continue' : 'Check',
              width: double.infinity,
              onPressed: isRevealed ? onNext : onSubmit,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Answer Field ──────────────────────────────────────────────

class _AnswerField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isRevealed;
  final bool? isCorrect;
  final String correctAnswer;
  final VoidCallback onSubmit;

  const _AnswerField({
    required this.controller,
    required this.focusNode,
    required this.isRevealed,
    required this.isCorrect,
    required this.correctAnswer,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.border;
    if (isRevealed) {
      borderColor = (isCorrect ?? false) ? AppColors.success : AppColors.error;
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: !isRevealed,
      autofocus: true,
      style: AppTextStyles.body,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        hintText: 'Type translation...',
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.textHint,
        ),
        filled: true,
        fillColor: isRevealed
            ? (isCorrect ?? false)
                ? AppColors.success.withOpacity(0.06)
                : AppColors.error.withOpacity(0.06)
            : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        suffixIcon: isRevealed
            ? Icon(
                (isCorrect ?? false) ? Icons.check : Icons.close,
                color:
                    (isCorrect ?? false) ? AppColors.success : AppColors.error,
              )
            : null,
      ),
    );
  }
}

// ─── Result Feedback ───────────────────────────────────────────

class _ResultFeedback extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;

  const _ResultFeedback({
    required this.isCorrect,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    if (isCorrect) {
      return Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.correct,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.cancel_outlined,
              size: 18,
              color: AppColors.error,
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.incorrect,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: AppTextStyles.body,
            children: [
              const TextSpan(
                text: '${AppStrings.correctAnswer} ',
                style: AppTextStyles.caption,
              ),
              TextSpan(
                text: correctAnswer,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
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
