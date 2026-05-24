import '../../repositories/dictionary_repository.dart';

class MarkWordReviewed {
  final DictionaryRepository _repository;
  MarkWordReviewed(this._repository);

  Future<void> call({
    required String userId,
    required String dictionaryId,
    required String wordId,
    required int currentStage,
  }) =>
      _repository.markWordReviewed(
        userId: userId,
        dictionaryId: dictionaryId,
        wordId: wordId,
        currentStage: currentStage,
      );
}
