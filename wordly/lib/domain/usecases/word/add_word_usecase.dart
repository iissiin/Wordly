import '../../entities/word_entity.dart';
import '../../repositories/word_repository.dart';

class AddWordParams {
  final String packId;
  final String userId;
  final String word;
  final String translation;
  final String? example;
  final String? transcription;

  const AddWordParams({
    required this.packId,
    required this.userId,
    required this.word,
    required this.translation,
    this.example,
    this.transcription,
  });
}

class AddWordUseCase {
  final WordRepository _repository;

  AddWordUseCase(this._repository);

  Future<WordEntity> call(AddWordParams params) {
    return _repository.addWord(
      packId: params.packId,
      userId: params.userId,
      word: params.word,
      translation: params.translation,
      example: params.example,
      transcription: params.transcription,
    );
  }
}
