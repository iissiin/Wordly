import '../entities/review_entity.dart';
import '../entities/word_entity.dart';

abstract class ReviewRepository {
  // Сохранить результат повторения и обновить слово
  Future<WordEntity> submitReview({
    required String wordId,
    required String userId,
    required ReviewResult result,
  });

  // История повторений слова
  Future<List<ReviewEntity>> getWordHistory(String wordId);

  // Статистика пользователя за период
  Future<Map<DateTime, int>> getReviewStats({
    required String userId,
    required DateTime from,
    required DateTime to,
  });
}
