import '../../repositories/dictionary_repository.dart';

class DeleteDictionary {
  final DictionaryRepository _repository;
  DeleteDictionary(this._repository);

  Future<void> call({
    required String userId,
    required String dictionaryId,
  }) =>
      _repository.deleteDictionary(
        userId: userId,
        dictionaryId: dictionaryId,
      );
}
