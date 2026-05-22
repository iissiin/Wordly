import '../entities/word_entity.dart';

abstract class WordRepository {
  // Все слова пака (real-time)
  Stream<List<WordEntity>> watchWords(String packId);

  // Слова для повторения прямо сейчас (по всем пакам)
  Future<List<WordEntity>> getDueWords(String userId);

  // Добавить слово
  Future<WordEntity> addWord({
    required String packId,
    required String userId,
    required String word,
    required String translation,
    String? example,
    String? transcription,
  });

  // Обновить слово (после повторения)
  Future<void> updateWord(WordEntity word);

  // Удалить слово
  Future<void> deleteWord(String wordId);
}
