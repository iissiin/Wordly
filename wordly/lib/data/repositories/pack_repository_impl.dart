import '../../domain/entities/pack_entity.dart';
import '../../domain/repositories/pack_repository.dart';
import '../../facade/firebase_facade.dart';

class PackRepositoryImpl implements PackRepository {
  final FirebaseFacade _facade;

  PackRepositoryImpl(this._facade);

  @override
  Stream<List<PackEntity>> watchPacks(String userId) =>
      _facade.watchPacks(userId);

  @override
  Future<PackEntity> createPack({
    required String userId,
    required String title,
    String? description,
    String? emoji,
    int colorIndex = 0,
  }) =>
      _facade.createPack(
        userId: userId,
        title: title,
        description: description,
        emoji: emoji,
        colorIndex: colorIndex,
      );

  @override
  Future<void> updatePack(PackEntity pack) => _facade.updatePack(pack);

  @override
  Future<void> deletePack(String packId) => _facade.deletePack(packId);
}
