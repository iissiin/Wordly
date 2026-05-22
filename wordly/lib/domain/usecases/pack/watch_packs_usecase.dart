import '../../entities/pack_entity.dart';
import '../../repositories/pack_repository.dart';

class WatchPacksUseCase {
  final PackRepository _repository;

  WatchPacksUseCase(this._repository);

  Stream<List<PackEntity>> call(String userId) {
    return _repository.watchPacks(userId);
  }
}
