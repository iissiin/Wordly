import 'package:equatable/equatable.dart';
import 'word.dart';

class Dictionary extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<Word> words;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Dictionary({
    required this.id,
    required this.name,
    this.description = '',
    this.words = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get wordCount => words.length;

  int get dueCount => words.where((w) => w.isDueForReview).length;

  @override
  List<Object?> get props =>
      [id, name, description, words, createdAt, updatedAt];
}
