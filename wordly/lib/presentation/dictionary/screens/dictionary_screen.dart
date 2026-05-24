import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/dictionary.dart';
import '../../../domain/entities/word.dart';
import '../cubit/dictionary_cubit.dart';
import '../cubit/dictionary_state.dart';
import '../widgets/progress_track_widget.dart';

class DictionaryScreen extends StatefulWidget {
  final Dictionary dictionary;

  const DictionaryScreen({super.key, required this.dictionary});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DictionaryCubit>().loadDictionary(widget.dictionary.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DictionaryCubit, DictionaryState>(
      listener: (context, state) {
        if (state is DictionaryOperationSuccess) {
          if (state.message == 'Dictionary deleted') {
            context.go('/');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is DictionaryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        // Берём актуальный словарь из стрима,
        // или исходный пока стрим не пришёл
        final dictionary =
            state is DictionarySuccess && state.dictionary != null
                ? state.dictionary!
                : widget.dictionary;

        return Scaffold(
          appBar: AppBar(
            title: Text(dictionary.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () => _showOptions(context, dictionary),
                tooltip: 'Options',
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (dictionary.words.isNotEmpty) ...[
                      ProgressTrackWidget(
                        words: dictionary.words,
                        dictionaryId: dictionary.id,
                        onMarkAllReviewed: () =>
                            _markAllReviewed(context, dictionary),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (dictionary.words.length >= 2) ...[
                      _QuizButtons(dictionary: dictionary),
                      const SizedBox(height: 16),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${dictionary.wordCount} ${AppStrings.words}',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ]),
                ),
              ),
              if (dictionary.words.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No words yet.\nTap ··· to edit this dictionary.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == dictionary.words.length) {
                          return const SizedBox(height: 24);
                        }
                        final word = dictionary.words[index];
                        return _WordRow(
                          word: word,
                          isLast: index == dictionary.words.length - 1,
                          dictionaryId: dictionary.id,
                        );
                      },
                      childCount: dictionary.words.length + 1,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showOptions(BuildContext context, Dictionary dictionary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text(AppStrings.edit),
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/dictionary/${dictionary.id}/edit',
                  extra: dictionary,
                );
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              title: const Text(
                AppStrings.deleteDictionary,
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, dictionary);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Dictionary dictionary) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.deleteDictionary),
        content: const Text(AppStrings.deleteDictionaryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DictionaryCubit>().deleteDictionary(dictionary.id);
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _markAllReviewed(BuildContext context, Dictionary dictionary) {
    for (final word in dictionary.words) {
      if (word.isDueForReview && !word.isCompleted) {
        context.read<DictionaryCubit>().markWordReviewed(
              dictionaryId: dictionary.id,
              wordId: word.id,
              currentStage: word.repetitionStage,
            );
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All words marked as reviewed')),
    );
  }
}

// ─── Quiz Buttons ──────────────────────────────────────────────

class _QuizButtons extends StatelessWidget {
  final Dictionary dictionary;

  const _QuizButtons({required this.dictionary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuizButton(
            icon: Icons.style_outlined,
            label: AppStrings.flashCards,
            onTap: () => context.push(
              '/dictionary/${dictionary.id}/flashcards',
              extra: dictionary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuizButton(
            icon: Icons.edit_outlined,
            label: AppStrings.writtenInput,
            onTap: () => context.push(
              '/dictionary/${dictionary.id}/written',
              extra: dictionary,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuizButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ─── Word Row ──────────────────────────────────────────────────
class _WordRow extends StatelessWidget {
  final Word word;
  final bool isLast;
  final String dictionaryId;

  const _WordRow({
    required this.word,
    required this.isLast,
    required this.dictionaryId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  word.original,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: Text(
                  word.translation,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
