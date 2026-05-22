import 'package:equatable/equatable.dart';

enum ReviewResult {
  correct, // пользователь ответил правильно
  incorrect, // пользователь ответил неправильно
}

class ReviewEntity extends Equatable {
  final String id;
  final String wordId;
  final String userId;
  final ReviewResult result;
  final int stageAfterReview; // на какой стадии слово после повторения
  final DateTime reviewedAt;

  const ReviewEntity({
    required this.id,
    required this.wordId,
    required this.userId,
    required this.result,
    required this.stageAfterReview,
    required this.reviewedAt,
  });

  @override
  List<Object?> get props => [
        id,
        wordId,
        userId,
        result,
        stageAfterReview,
        reviewedAt,
      ];
}
