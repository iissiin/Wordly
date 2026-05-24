import 'package:wordly/domain/entities/dictionary.dart';
import 'package:wordly/domain/entities/word.dart';

abstract class DictionaryRepository {
  Stream<List<Dictionary>> watchDictionaries(String userId);

  Future<void> createDictionary({
    required String userId,
    required String name,
    required String description,
    required List<Word> words,
  });

  Future<void> updateDictionary({
    required String userId,
    required String dictionaryId,
    required String name,
    required String description,
    required List<Word> wordsToAdd,
    required List<String> wordIdsToDelete,
  });

  Future<void> deleteDictionary({
    required String userId,
    required String dictionaryId,
  });

  Future<void> markWordReviewed({
    required String userId,
    required String dictionaryId,
    required String wordId,
    required int currentStage,
  });

  Stream<Dictionary> watchDictionary(String userId, String dictionaryId);
}
