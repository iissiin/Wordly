import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/word.dart';

class WordModel extends Word {
  const WordModel({
    required super.id,
    required super.original,
    required super.translation,
    super.repetitionStage,
    super.lastReviewed,
    super.nextReview,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as String? ?? '',
      original: map['original'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
      repetitionStage: map['repetitionStage'] as int? ?? 0,
      lastReviewed: _toDateTime(map['lastReviewed']),
      nextReview: _toDateTime(map['nextReview']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'original': original,
      'translation': translation,
      'repetitionStage': repetitionStage,
      'lastReviewed':
          lastReviewed != null ? Timestamp.fromDate(lastReviewed!) : null,
      'nextReview': nextReview != null ? Timestamp.fromDate(nextReview!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'repetitionStage': repetitionStage,
      'lastReviewed':
          lastReviewed != null ? Timestamp.fromDate(lastReviewed!) : null,
      'nextReview': nextReview != null ? Timestamp.fromDate(nextReview!) : null,
    };
  }

  WordModel copyWithProgress({
    required int stage,
    required DateTime reviewed,
    required DateTime? next,
  }) {
    return WordModel(
      id: id,
      original: original,
      translation: translation,
      repetitionStage: stage,
      lastReviewed: reviewed,
      nextReview: next,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
