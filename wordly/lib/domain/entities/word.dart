import 'package:equatable/equatable.dart';

class Word extends Equatable {
  final String id;
  final String original;
  final String translation;
  final int repetitionStage; // 0–7
  final DateTime? lastReviewed;
  final DateTime? nextReview;

  const Word({
    required this.id,
    required this.original,
    required this.translation,
    this.repetitionStage = 0,
    this.lastReviewed,
    this.nextReview,
  });

  bool get isDueForReview {
    if (nextReview == null) return true;
    return DateTime.now().isAfter(nextReview!);
  }

  bool get isCompleted => repetitionStage >= 7;

  @override
  List<Object?> get props => [
        id,
        original,
        translation,
        repetitionStage,
        lastReviewed,
        nextReview,
      ];
}
