import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/word.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/dictionary/create_dictionary.dart';
import '../../../domain/usecases/dictionary/delete_dictionary.dart';
import '../../../domain/usecases/dictionary/update_dictionary.dart';
import '../../../domain/usecases/dictionary/watch_dictionary.dart';
import '../../../domain/usecases/word/mark_word_reviewed.dart';
import '../../../injection_container.dart';
import 'dictionary_state.dart';

class DictionaryCubit extends Cubit<DictionaryState> {
  final CreateDictionary _createDictionary;
  final UpdateDictionary _updateDictionary;
  final DeleteDictionary _deleteDictionary;
  final MarkWordReviewed _markWordReviewed;
  final WatchDictionary _watchDictionary;

  StreamSubscription? _dictionarySubscription;

  DictionaryCubit({
    required CreateDictionary createDictionary,
    required UpdateDictionary updateDictionary,
    required DeleteDictionary deleteDictionary,
    required MarkWordReviewed markWordReviewed,
    required WatchDictionary watchDictionary,
  })  : _createDictionary = createDictionary,
        _updateDictionary = updateDictionary,
        _deleteDictionary = deleteDictionary,
        _markWordReviewed = markWordReviewed,
        _watchDictionary = watchDictionary,
        super(const DictionaryInitial());

  String? get _userId => sl<AuthRepository>().currentUser?.id;

  // ─── WATCH ───────────────────────────────────────────────

  void loadDictionary(String dictionaryId) {
    final userId = _userId;
    if (userId == null) return;

    _dictionarySubscription?.cancel();
    _dictionarySubscription = _watchDictionary(userId, dictionaryId).listen(
      (dictionary) => emit(DictionarySuccess(dictionary: dictionary)),
      onError: (e) => emit(DictionaryError(e.toString())),
    );
  }

  // ─── CREATE ──────────────────────────────────────────────

  Future<void> createDictionary({
    required String name,
    required String description,
    required List<Word> words,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    emit(const DictionaryLoading());
    try {
      await _createDictionary(
        userId: userId,
        name: name,
        description: description,
        words: words,
      );
      emit(const DictionaryOperationSuccess('Dictionary created'));
    } on Exception catch (e) {
      emit(DictionaryError(e.toString()));
    }
  }

  // ─── UPDATE ──────────────────────────────────────────────

  Future<void> updateDictionary({
    required String dictionaryId,
    required String name,
    required String description,
    required List<Word> wordsToAdd,
    required List<String> wordIdsToDelete,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    emit(const DictionaryLoading());
    try {
      await _updateDictionary(
        userId: userId,
        dictionaryId: dictionaryId,
        name: name,
        description: description,
        wordsToAdd: wordsToAdd,
        wordIdsToDelete: wordIdsToDelete,
      );
      emit(const DictionaryOperationSuccess('Dictionary updated'));
    } on Exception catch (e) {
      emit(DictionaryError(e.toString()));
    }
  }

  // ─── DELETE ──────────────────────────────────────────────

  Future<void> deleteDictionary(String dictionaryId) async {
    final userId = _userId;
    if (userId == null) return;

    _dictionarySubscription?.cancel();
    emit(const DictionaryLoading());
    try {
      await _deleteDictionary(
        userId: userId,
        dictionaryId: dictionaryId,
      );
      emit(const DictionaryOperationSuccess('Dictionary deleted'));
    } on Exception catch (e) {
      emit(DictionaryError(e.toString()));
    }
  }

  // ─── MARK REVIEWED ───────────────────────────────────────

  Future<void> markWordReviewed({
    required String dictionaryId,
    required String wordId,
    required int currentStage,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _markWordReviewed(
        userId: userId,
        dictionaryId: dictionaryId,
        wordId: wordId,
        currentStage: currentStage,
      );
    } on Exception catch (e) {
      emit(DictionaryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _dictionarySubscription?.cancel();
    return super.close();
  }
}
