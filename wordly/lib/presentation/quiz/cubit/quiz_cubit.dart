import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/dictionary.dart';
import '../../../domain/entities/word.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(const QuizInitial());

  // Очередь слов — слова остаются до правильного ответа
  final List<Word> _queue = [];
  int _correctCount = 0;
  int _totalWords = 0;

  // ─── INIT ────────────────────────────────────────────────

  void startQuiz(Dictionary dictionary) {
    if (dictionary.words.length < 2) {
      emit(const QuizError('Need at least 2 words'));
      return;
    }

    _queue.clear();
    _correctCount = 0;

    // Перемешиваем слова
    _queue.addAll(List.from(dictionary.words)..shuffle());
    _totalWords = _queue.length;

    _emitCurrent();
  }

  void _emitCurrent() {
    if (_queue.isEmpty) {
      emit(QuizCompleted(
        correctCount: _correctCount,
        totalWords: _totalWords,
      ));
      return;
    }

    emit(QuizInProgress(
      currentWord: _queue.first,
      currentIndex: _totalWords - _queue.length,
      totalWords: _totalWords,
      correctCount: _correctSoFar(),
    ));
  }

  int _correctSoFar() => _correctCount;

  // ─── FLASHCARD LOGIC ─────────────────────────────────────

  /// Показать перевод (flip)
  void revealAnswer() {
    final state = this.state;
    if (state is! QuizInProgress) return;

    emit(QuizInProgress(
      currentWord: state.currentWord,
      currentIndex: state.currentIndex,
      totalWords: state.totalWords,
      correctCount: state.correctCount,
      isAnswerRevealed: true,
    ));
  }

  /// Пользователь отметил "знаю" — слово убирается из очереди
  void markCorrect() {
    final state = this.state;
    if (state is! QuizInProgress) return;

    _correctCount++;
    _queue.removeAt(0);
    _emitCurrent();
  }

  /// Пользователь отметил "не знаю" — слово уходит в конец очереди
  void markIncorrect() {
    final state = this.state;
    if (state is! QuizInProgress) return;

    final word = _queue.removeAt(0);
    _queue.add(word); // в конец очереди
    _emitCurrent();
  }

  // ─── WRITTEN LOGIC ───────────────────────────────────────

  /// Проверить введённый ответ
  void checkAnswer(String input) {
    final state = this.state;
    if (state is! QuizInProgress) return;

    final correct =
        _normalize(input) == _normalize(state.currentWord.translation);

    if (correct) {
      // Правильно — показываем результат, потом убираем слово
      emit(QuizInProgress(
        currentWord: state.currentWord,
        currentIndex: state.currentIndex,
        totalWords: state.totalWords,
        correctCount: state.correctCount,
        isAnswerRevealed: true,
        lastAnswerCorrect: true,
      ));
      _correctCount++;
    } else {
      // Неправильно — показываем правильный ответ
      // слово уйдёт в конец очереди после нажатия "Continue"
      emit(QuizInProgress(
        currentWord: state.currentWord,
        currentIndex: state.currentIndex,
        totalWords: state.totalWords,
        correctCount: state.correctCount,
        isAnswerRevealed: true,
        lastAnswerCorrect: false,
      ));
    }
  }

  /// Перейти к следующему слову после показа результата
  void nextWord() {
    final state = this.state;
    if (state is! QuizInProgress) return;

    if (state.lastAnswerCorrect == true) {
      // Правильный ответ — убираем слово
      _queue.removeAt(0);
    } else {
      // Неправильный — в конец очереди
      final word = _queue.removeAt(0);
      _queue.add(word);
    }

    _emitCurrent();
  }

  /// Нормализация для сравнения: нижний регистр, без пробелов по краям
  String _normalize(String s) => s.trim().toLowerCase();
}
