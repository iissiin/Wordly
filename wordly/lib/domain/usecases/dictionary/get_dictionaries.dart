import '../../entities/dictionary.dart';
import '../../repositories/dictionary_repository.dart';

class GetDictionaries {
  final DictionaryRepository _repository;
  GetDictionaries(this._repository);

  Stream<List<Dictionary>> call(String userId) =>
      _repository.watchDictionaries(userId);
}
