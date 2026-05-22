import 'package:equatable/equatable.dart';

// Статус слова в системе повторения
enum WordStatus {
  newWord, // ещё не изучалось
  learning, // в процессе изучения (стадии 1-7)
  learned, // выучено (прошло все 8 стадий)
}

class WordEntity extends Equatable {
  final String id;
  final String packId;
  final String userId;
  final String word; // само слово (например "apple")
  final String translation; // перевод ("яблоко")
  final String? example; // пример использования
  final String? transcription; // транскрипция [ˈæp.əl]
  final int reviewStage; // текущая стадия повторения (0-8)
  final DateTime? nextReviewAt; // когда следующее повторение
  final DateTime? lastReviewAt; // когда было последнее повторение
  final WordStatus status;
  final DateTime createdAt;

  const WordEntity({
    required this.id,
    required this.packId,
    required this.userId,
    required this.word,
    required this.translation,
    this.example,
    this.transcription,
    this.reviewStage = 0,
    this.nextReviewAt,
    this.lastReviewAt,
    this.status = WordStatus.newWord,
    required this.createdAt,
  });

  // Нужно ли повторять слово прямо сейчас?
  bool get isDue {
    if (status == WordStatus.learned) return false;
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  // Выучено ли слово полностью?
  bool get isFullyLearned => reviewStage >= 8;

  @override
  List<Object?> get props => [
        id,
        packId,
        userId,
        word,
        translation,
        example,
        transcription,
        reviewStage,
        nextReviewAt,
        lastReviewAt,
        status,
        createdAt,
      ];
}
