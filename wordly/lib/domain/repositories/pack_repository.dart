import '../entities/pack_entity.dart';

abstract class PackRepository {
  // Получить все паки пользователя (real-time поток из Firestore)
  Stream<List<PackEntity>> watchPacks(String userId);

  // Создать новый пак
  Future<PackEntity> createPack({
    required String userId,
    required String title,
    String? description,
    String? emoji,
    int colorIndex,
  });

  // Обновить пак
  Future<void> updatePack(PackEntity pack);

  // Удалить пак и все его слова
  Future<void> deletePack(String packId);
}
