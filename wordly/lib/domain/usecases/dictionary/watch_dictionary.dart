import '../../entities/dictionary.dart';
import '../../repositories/dictionary_repository.dart';

class WatchDictionary {
  final DictionaryRepository _repository;
  WatchDictionary(this._repository);

  Stream<Dictionary> call(String userId, String dictionaryId) =>
      _repository.watchDictionary(userId, dictionaryId);
}
