import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordly/domain/entities/quiz_settings.dart';
import '../../../domain/entities/dictionary.dart';
import '../../../domain/entities/word.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(const QuizInitial());

  final List<Word> _queue = [];
  int _totalWords = 0;
  TranslationDirection _direction = TranslationDirection.originalToTranslation;

  // Слова правильные с первой попытки
  final Set<String> _correctFirstAttempt = {};
  // Слова которые уже пробовали (первая попытка сделана)
  final Set<String> _attempted = {};

  // Итоговый счёт — только первые правильные ответы
  int get _correctCount => _correctFirstAttempt.length;

  // ─── GETTERS ─────────────────────────────────────────────

  String questionFor(Word word) =>
      _direction == TranslationDirection.originalToTranslation
          ? word.original
          : word.translation;

  String answerFor(Word word) =>
      _direction == TranslationDirection.originalToTranslation
          ? word.translation
          : word.original;

  // ─── INIT ────────────────────────────────────────────────

  void startQuiz(Dictionary dictionary, QuizSettings settings) {
    if (dictionary.words.length < 2) {
      emit(const QuizError('Need at least 2 words'));
      return;
    }

    _queue.clear();
    _correctFirstAttempt.clear();
    _attempted.clear();
    _direction = settings.direction;

    final words = List.of(dictionary.words);
    if (settings.randomOrder) words.shuffle();

    _queue.addAll(words);
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
      correctCount: _correctCount,
    ));
  }

  // ─── FLASHCARD ───────────────────────────────────────────

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

  void markCorrect() {
    final state = this.state;
    if (state is! QuizInProgress) return;

    final wordId = state.currentWord.id;

    // Считаем правильным только если это первая попытка
    if (!_attempted.contains(wordId)) {
      _correctFirstAttempt.add(wordId);
    }
    _attempted.add(wordId);

    _queue.removeAt(0);
    _emitCurrent();
  }

  void markIncorrect() {
    final state = this.state;
    if (state is! QuizInProgress) return;

    final wordId = state.currentWord.id;

    // Отмечаем что первая попытка была — и она неправильная
    _attempted.add(wordId);
    // Убираем из правильных на случай если было добавлено
    _correctFirstAttempt.remove(wordId);

    final word = _queue.removeAt(0);
    _queue.add(word);
    _emitCurrent();
  }

  // ─── WRITTEN ─────────────────────────────────────────────

  void checkAnswer(String input) {
    final state = this.state;
    if (state is! QuizInProgress) return;

    final wordId = state.currentWord.id;
    final correct =
        _normalize(input) == _normalize(answerFor(state.currentWord));

    if (correct) {
      // Правильно с первой попытки — засчитываем
      if (!_attempted.contains(wordId)) {
        _correctFirstAttempt.add(wordId);
      }
      _attempted.add(wordId);

      emit(QuizInProgress(
        currentWord: state.currentWord,
        currentIndex: state.currentIndex,
        totalWords: state.totalWords,
        correctCount: _correctCount,
        isAnswerRevealed: true,
        lastAnswerCorrect: true,
      ));
    } else {
      // Неправильно — первая попытка провалена
      _attempted.add(wordId);
      _correctFirstAttempt.remove(wordId);

      emit(QuizInProgress(
        currentWord: state.currentWord,
        currentIndex: state.currentIndex,
        totalWords: state.totalWords,
        correctCount: _correctCount,
        isAnswerRevealed: true,
        lastAnswerCorrect: false,
      ));
    }
  }

  void nextWord() {
    final state = this.state;
    if (state is! QuizInProgress) return;

    if (state.lastAnswerCorrect == true) {
      _queue.removeAt(0);
    } else {
      final word = _queue.removeAt(0);
      _queue.add(word);
    }

    _emitCurrent();
  }

  String _normalize(String s) => s.trim().toLowerCase();
}
