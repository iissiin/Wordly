import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final int totalWordsLearned; // сколько слов выучено всего
  final int currentStreak; // дней подряд занимается
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.totalWordsLearned = 0,
    this.currentStreak = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        photoUrl,
        totalWordsLearned,
        currentStreak,
        createdAt,
      ];
}
