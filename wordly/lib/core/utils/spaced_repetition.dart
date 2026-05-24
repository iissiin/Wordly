/// Интервалы повторения (в минутах):
/// Stage 0 → сразу
/// Stage 1 → 20 минут
/// Stage 2 → 8 часов
/// Stage 3 → 24 часа
/// Stage 4 → 3 дня
/// Stage 5 → неделя
/// Stage 6 → 2 недели
/// Stage 7 → месяц (завершено)

// ignore_for_file: dangling_library_doc_comments

class SpacedRepetition {
  SpacedRepetition._();

  static const List<Duration> _intervals = [
    Duration(minutes: 0),
    Duration(minutes: 20),
    Duration(hours: 8),
    Duration(hours: 24),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
  ];

  static const List<String> stageLabels = [
    'Now',
    '20 min',
    '8 hrs',
    '1 day',
    '3 days',
    '1 week',
    '2 weeks',
    '1 month',
  ];

  static const int maxStage = 7;

  /// Вычислить следующую дату повторения
  static DateTime? nextReviewDate(int currentStage) {
    final nextStage = currentStage + 1;
    if (nextStage > maxStage) return null; // завершено
    return DateTime.now().add(_intervals[nextStage]);
  }

  /// Следующий stage
  static int nextStage(int current) {
    return (current + 1).clamp(0, maxStage);
  }

  static Duration intervalAt(int stage) {
    if (stage < 0 || stage >= _intervals.length) {
      return _intervals.last;
    }
    return _intervals[stage];
  }
}
