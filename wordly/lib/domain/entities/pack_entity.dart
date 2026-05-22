import 'package:equatable/equatable.dart';

class PackEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? emoji; // иконка пака, например 🇬🇧
  final int colorIndex; // индекс цвета из AppColors.packGradients
  final int totalWords; // сколько слов в паке
  final int learnedWords; // сколько слов выучено (прошли все 8 стадий)
  final int dueWords; // сколько слов нужно повторить СЕЙЧАС
  final DateTime createdAt;
  final DateTime updatedAt;

  const PackEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.emoji,
    this.colorIndex = 0,
    this.totalWords = 0,
    this.learnedWords = 0,
    this.dueWords = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Вычисляемое поле — процент прогресса пака
  double get progressPercent => totalWords == 0 ? 0 : learnedWords / totalWords;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        emoji,
        colorIndex,
        totalWords,
        learnedWords,
        dueWords,
        createdAt,
        updatedAt,
      ];
}
