import 'package:equatable/equatable.dart';
import '../../../domain/entities/word.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizInProgress extends QuizState {
  final Word currentWord;
  final int currentIndex;
  final int totalWords;
  final int correctCount;
  final bool isAnswerRevealed; // для flashcard — показан ли перевод
  final bool? lastAnswerCorrect; // null = ещё не отвечено

  const QuizInProgress({
    required this.currentWord,
    required this.currentIndex,
    required this.totalWords,
    required this.correctCount,
    this.isAnswerRevealed = false,
    this.lastAnswerCorrect,
  });

  @override
  List<Object?> get props => [
        currentWord,
        currentIndex,
        totalWords,
        correctCount,
        isAnswerRevealed,
        lastAnswerCorrect,
      ];
}

class QuizCompleted extends QuizState {
  final int correctCount;
  final int totalWords;

  const QuizCompleted({
    required this.correctCount,
    required this.totalWords,
  });

  @override
  List<Object?> get props => [correctCount, totalWords];
}

class QuizError extends QuizState {
  final String message;
  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}
