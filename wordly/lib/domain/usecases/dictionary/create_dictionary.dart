import '../../entities/word.dart';
import '../../repositories/dictionary_repository.dart';

class CreateDictionary {
  final DictionaryRepository _repository;
  CreateDictionary(this._repository);

  Future<void> call({
    required String userId,
    required String name,
    required String description,
    required List<Word> words,
  }) =>
      _repository.createDictionary(
        userId: userId,
        name: name,
        description: description,
        words: words,
      );
}
