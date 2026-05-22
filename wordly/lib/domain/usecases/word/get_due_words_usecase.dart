import '../../entities/word_entity.dart';
import '../../repositories/word_repository.dart';

class GetDueWordsUseCase {
  final WordRepository _repository;

  GetDueWordsUseCase(this._repository);

  Future<List<WordEntity>> call(String userId) {
    return _repository.getDueWords(userId);
  }
}
