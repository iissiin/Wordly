import '../../domain/entities/review_entity.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../../facade/firebase_facade.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  // ignore: unused_field
  final FirebaseFacade _facade;

  ReviewRepositoryImpl(this._facade);

  @override
  Future<WordEntity> submitReview({
    required String wordId,
    required String userId,
    required ReviewResult result,
  }) async {
    throw UnimplementedError('Используй facade.submitReview напрямую');
  }

  @override
  Future<List<ReviewEntity>> getWordHistory(String wordId) async => [];

  @override
  Future<Map<DateTime, int>> getReviewStats({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async =>
      {};
}
