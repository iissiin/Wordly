import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../domain/entities/dictionary.dart';
import '../../../domain/entities/word.dart';
import '../cubit/dictionary_cubit.dart';
import '../cubit/dictionary_state.dart';
import '../models/word_entry.dart';

class DictionaryFormScreen extends StatefulWidget {
  final Dictionary? dictionary; // null = создание

  const DictionaryFormScreen({super.key, this.dictionary});

  @override
  State<DictionaryFormScreen> createState() => _DictionaryFormScreenState();
}

class _DictionaryFormScreenState extends State<DictionaryFormScreen> {
  // Лимиты
  static const int _maxWords = 200;
  static const int _minWords = 2;
  static const int _maxWordLength = 100;
  static const int _maxNameLength = 60;
  static const int _maxDescLength = 200;

  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final List<WordEntry> _entries;

  // id слов которые нужно удалить (только при редактировании)
  final List<String> _wordIdsToDelete = [];

  bool get _isEditing => widget.dictionary != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.dictionary?.name ?? '',
    );
    _descController = TextEditingController(
      text: widget.dictionary?.description ?? '',
    );

    // Заполняем существующие слова или добавляем 2 пустых
    if (_isEditing && widget.dictionary!.words.isNotEmpty) {
      _entries = widget.dictionary!.words
          .map((w) => WordEntry(
                id: w.id,
                original: w.original,
                translation: w.translation,
              ))
          .toList();
    } else {
      _entries = [WordEntry(), WordEntry()];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  // ─── VALIDATION ─────────────────────────────────────────

  String? _nameError;
  String? _wordCountError;

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Dictionary name is required'
          : null;

      final validEntries = _entries.where((e) => e.isValid).toList();
      _wordCountError =
          validEntries.length < _minWords ? AppStrings.minWordsError : null;
    });

    return _nameError == null && _wordCountError == null;
  }

  // ─── WORD MANAGEMENT ────────────────────────────────────

  void _addWord() {
    if (_entries.length >= _maxWords) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.maxWordsError)),
      );
      return;
    }
    setState(() => _entries.add(WordEntry()));
  }

  void _removeWord(int index) {
    if (_entries.length <= _minWords) return;

    final entry = _entries[index];
    if (!entry.isNew) {
      _wordIdsToDelete.add(entry.id);
    }
    entry.dispose();
    setState(() => _entries.removeAt(index));
  }

  // ─── SUBMIT ─────────────────────────────────────────────

  void _submit() {
    if (!_validate()) return;

    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    final validEntries = _entries.where((e) => e.isValid).toList();

    if (_isEditing) {
      // Разделяем новые и существующие слова
      final wordsToAdd = validEntries
          .where((e) => e.isNew)
          .map((e) => Word(
                id: '',
                original: e.original,
                translation: e.translation,
              ))
          .toList();

      context.read<DictionaryCubit>().updateDictionary(
            dictionaryId: widget.dictionary!.id,
            name: name,
            description: description,
            wordsToAdd: wordsToAdd,
            wordIdsToDelete: _wordIdsToDelete,
          );
    } else {
      final words = validEntries
          .map((e) => Word(
                id: '',
                original: e.original,
                translation: e.translation,
              ))
          .toList();

      context.read<DictionaryCubit>().createDictionary(
            name: name,
            description: description,
            words: words,
          );
    }
  }

  // ─── BUILD ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<DictionaryCubit, DictionaryState>(
      listener: (context, state) {
        if (state is DictionaryOperationSuccess) {
          context.go('/');
        }
        if (state is DictionaryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? AppStrings.editDictionary : AppStrings.newDictionary,
          ),
        ),
        body: BlocBuilder<DictionaryCubit, DictionaryState>(
          builder: (context, state) {
            final isLoading = state is DictionaryLoading;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Name ──────────────────────────
                      AppTextField(
                        controller: _nameController,
                        label: AppStrings.dictionaryName,
                        hint: 'e.g. Spanish basics',
                        maxLength: _maxNameLength,
                        autofocus: !_isEditing,
                        errorText: _nameError,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            _maxNameLength,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Description ───────────────────
                      AppTextField(
                        controller: _descController,
                        label: AppStrings.dictionaryDescription,
                        hint: 'Optional',
                        maxLines: 2,
                        maxLength: _maxDescLength,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            _maxDescLength,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Words section ─────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Words',
                            style: AppTextStyles.heading3,
                          ),
                          Text(
                            '${_entries.length}/$_maxWords',
                            style: AppTextStyles.small,
                          ),
                        ],
                      ),

                      if (_wordCountError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _wordCountError!,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // ── Word entries ──────────────────
                      ...List.generate(_entries.length, (index) {
                        return _WordEntryRow(
                          key: ObjectKey(_entries[index]),
                          entry: _entries[index],
                          index: index,
                          canDelete: _entries.length > _minWords,
                          maxLength: _maxWordLength,
                          onDelete: () => _removeWord(index),
                          onChanged: () => setState(() {}),
                        );
                      }),

                      const SizedBox(height: 12),

                      // ── Add word button ───────────────
                      TextButton.icon(
                        onPressed: _addWord,
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          AppStrings.addWord,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // ── Save button ──────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: AppButton(
                    label: AppStrings.save,
                    isLoading: isLoading,
                    width: double.infinity,
                    onPressed: _submit,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Word Entry Row ────────────────────────────────────────────

class _WordEntryRow extends StatelessWidget {
  final WordEntry entry;
  final int index;
  final bool canDelete;
  final int maxLength;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _WordEntryRow({
    super.key,
    required this.entry,
    required this.index,
    required this.canDelete,
    required this.maxLength,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Index number ──────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 8),
            child: SizedBox(
              width: 20,
              child: Text(
                '${index + 1}',
                style: AppTextStyles.small,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // ── Original ──────────────────────────────
          Expanded(
            child: TextField(
              controller: entry.originalController,
              maxLength: maxLength,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              style: AppTextStyles.body,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                hintText: AppStrings.original,
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textHint,
                ),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Translation ───────────────────────────
          Expanded(
            child: TextField(
              controller: entry.translationController,
              maxLength: maxLength,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              style: AppTextStyles.body,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                hintText: AppStrings.translation,
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textHint,
                ),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ── Delete button ─────────────────────────
          if (canDelete)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textHint,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            )
          else
            const SizedBox(width: 36),
        ],
      ),
    );
  }
}
