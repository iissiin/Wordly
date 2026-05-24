import '../../entities/word.dart';
import '../../repositories/dictionary_repository.dart';

class UpdateDictionary {
  final DictionaryRepository _repository;
  UpdateDictionary(this._repository);

  Future<void> call({
    required String userId,
    required String dictionaryId,
    required String name,
    required String description,
    required List<Word> wordsToAdd,
    required List<String> wordIdsToDelete,
  }) =>
      _repository.updateDictionary(
        userId: userId,
        dictionaryId: dictionaryId,
        name: name,
        description: description,
        wordsToAdd: wordsToAdd,
        wordIdsToDelete: wordIdsToDelete,
      );
}
