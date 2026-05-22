import '../../domain/entities/word_entity.dart';
import '../../domain/repositories/word_repository.dart';
import '../../facade/firebase_facade.dart';

class WordRepositoryImpl implements WordRepository {
  final FirebaseFacade _facade;

  WordRepositoryImpl(this._facade);

  @override
  Stream<List<WordEntity>> watchWords(String packId) =>
      _facade.watchWords(packId);

  @override
  Future<List<WordEntity>> getDueWords(String userId) =>
      _facade.getDueWords(userId);

  @override
  Future<WordEntity> addWord({
    required String packId,
    required String userId,
    required String word,
    required String translation,
    String? example,
    String? transcription,
  }) =>
      _facade.addWord(
        packId: packId,
        userId: userId,
        word: word,
        translation: translation,
        example: example,
        transcription: transcription,
      );

  @override
  Future<void> updateWord(WordEntity word) async {}

  @override
  Future<void> deleteWord(String wordId) => _facade.deleteWord(wordId, '');
}
