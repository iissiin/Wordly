import 'package:wordly/domain/repositories/dictionary_repository.dart';

import '../../core/utils/spaced_repetition.dart';
import '../../domain/entities/dictionary.dart';
import '../../domain/entities/word.dart';
import '../../facade/firebase_facade.dart';
import '../models/dictionary_model.dart';
import '../models/word_model.dart';

class DictionaryRepositoryImpl implements DictionaryRepository {
  final FirebaseFacade _facade;

  DictionaryRepositoryImpl({required FirebaseFacade facade}) : _facade = facade;

  @override
  Stream<List<Dictionary>> watchDictionaries(String userId) {
    return _facade.watchDictionaries(userId).asyncMap(
      (dictMaps) async {
        final result = <Dictionary>[];

        for (final dictMap in dictMaps) {
          final dictionaryId = dictMap['id'] as String;

          // Загружаем слова для каждого словаря
          final wordMaps = await _facade
              .watchWords(userId: userId, dictionaryId: dictionaryId)
              .first;

          final words = wordMaps.map((w) => WordModel.fromMap(w)).toList();

          result.add(
            DictionaryModel.fromMap(dictMap, words: words),
          );
        }

        return result;
      },
    );
  }

  @override
  Future<void> createDictionary({
    required String userId,
    required String name,
    required String description,
    required List<Word> words,
  }) async {
    final dict = DictionaryModel(
      id: '',
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final dictionaryId = await _facade.createDictionary(
      userId: userId,
      data: dict.toCreateMap(),
    );

    if (words.isNotEmpty) {
      final wordMaps = words.map((w) {
        final model = WordModel(
          id: '',
          original: w.original,
          translation: w.translation,
        );
        return model.toMap();
      }).toList();

      await _facade.createWordsBatch(
        userId: userId,
        dictionaryId: dictionaryId,
        words: wordMaps,
      );
    }
  }

  @override
  Future<void> updateDictionary({
    required String userId,
    required String dictionaryId,
    required String name,
    required String description,
    required List<Word> wordsToAdd,
    required List<String> wordIdsToDelete,
  }) async {
    final dict = DictionaryModel(
      id: dictionaryId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _facade.updateDictionary(
      userId: userId,
      dictionaryId: dictionaryId,
      data: dict.toUpdateMap(),
    );

    if (wordIdsToDelete.isNotEmpty) {
      await _facade.deleteWordsBatch(
        userId: userId,
        dictionaryId: dictionaryId,
        wordIds: wordIdsToDelete,
      );
    }

    if (wordsToAdd.isNotEmpty) {
      final wordMaps = wordsToAdd.map((w) {
        final model = WordModel(
          id: '',
          original: w.original,
          translation: w.translation,
        );
        return model.toMap();
      }).toList();

      await _facade.createWordsBatch(
        userId: userId,
        dictionaryId: dictionaryId,
        words: wordMaps,
      );
    }
  }

  @override
  Future<void> deleteDictionary({
    required String userId,
    required String dictionaryId,
  }) async {
    await _facade.deleteDictionary(
      userId: userId,
      dictionaryId: dictionaryId,
    );
  }

  @override
  Future<void> markWordReviewed({
    required String userId,
    required String dictionaryId,
    required String wordId,
    required int currentStage,
  }) async {
    final nextStage = SpacedRepetition.nextStage(currentStage);
    final nextReview = SpacedRepetition.nextReviewDate(currentStage);
    final now = DateTime.now();

    final updated = WordModel(
      id: wordId,
      original: '',
      translation: '',
      repetitionStage: nextStage,
      lastReviewed: now,
      nextReview: nextReview,
    );

    await _facade.updateWord(
      userId: userId,
      dictionaryId: dictionaryId,
      wordId: wordId,
      data: updated.toUpdateMap(),
    );
  }

  @override
  Stream<Dictionary> watchDictionary(String userId, String dictionaryId) {
    return _facade
        .watchWords(userId: userId, dictionaryId: dictionaryId)
        .asyncMap((wordMaps) async {
      final dictMap = await _facade.getDictionary(
        userId: userId,
        dictionaryId: dictionaryId,
      );
      if (dictMap == null) throw Exception('Dictionary not found');
      final words = wordMaps.map((w) => WordModel.fromMap(w)).toList();
      return DictionaryModel.fromMap(dictMap, words: words);
    });
  }
}
