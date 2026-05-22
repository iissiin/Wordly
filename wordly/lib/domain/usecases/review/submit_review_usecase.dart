import '../../entities/review_entity.dart';
import '../../entities/word_entity.dart';
import '../../repositories/review_repository.dart';
import '../../../core/constants/app_constants.dart';

class SubmitReviewParams {
  final String wordId;
  final String userId;
  final ReviewResult result;

  const SubmitReviewParams({
    required this.wordId,
    required this.userId,
    required this.result,
  });
}

class SubmitReviewUseCase {
  final ReviewRepository _repository;

  SubmitReviewUseCase(this._repository);

  Future<WordEntity> call(SubmitReviewParams params) {
    return _repository.submitReview(
      wordId: params.wordId,
      userId: params.userId,
      result: params.result,
    );
  }

  // Статический метод расчёта следующего времени повторения.
  // Вынесен сюда — в бизнес-логику — а не в репозиторий.
  // Это SRP (Single Responsibility Principle).
  static DateTime? calculateNextReview({
    required int currentStage,
    required ReviewResult result,
  }) {
    // Если ответ неправильный — откатываемся на стадию назад
    final int nextStage = result == ReviewResult.correct
        ? currentStage + 1
        : (currentStage - 1).clamp(0, AppConstants.maxReviewStage);

    // Если достигли максимума — слово выучено, повторений больше нет
    if (nextStage >= AppConstants.maxReviewStage) return null;

    // Берём интервал для следующей стадии (в минутах)
    final int intervalMinutes = AppConstants.reviewIntervals[nextStage];

    return DateTime.now().add(Duration(minutes: intervalMinutes));
  }

  // Вычисляем новую стадию
  static int calculateNextStage({
    required int currentStage,
    required ReviewResult result,
  }) {
    if (result == ReviewResult.correct) {
      return (currentStage + 1).clamp(0, AppConstants.maxReviewStage);
    } else {
      return (currentStage - 1).clamp(0, AppConstants.maxReviewStage);
    }
  }
}
