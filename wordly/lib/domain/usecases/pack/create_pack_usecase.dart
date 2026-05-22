import '../../entities/pack_entity.dart';
import '../../repositories/pack_repository.dart';

class CreatePackParams {
  final String userId;
  final String title;
  final String? description;
  final String? emoji;
  final int colorIndex;

  const CreatePackParams({
    required this.userId,
    required this.title,
    this.description,
    this.emoji,
    this.colorIndex = 0,
  });
}

class CreatePackUseCase {
  final PackRepository _repository;

  CreatePackUseCase(this._repository);

  Future<PackEntity> call(CreatePackParams params) {
    return _repository.createPack(
      userId: params.userId,
      title: params.title,
      description: params.description,
      emoji: params.emoji,
      colorIndex: params.colorIndex,
    );
  }
}
