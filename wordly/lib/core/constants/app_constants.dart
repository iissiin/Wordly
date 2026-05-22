abstract class AppConstants {
  // Название приложения
  static const String appName = 'Wordly';

  // Firestore коллекции
  static const String usersCollection = 'users';
  static const String packsCollection = 'packs';
  static const String wordsCollection = 'words';

  // SharedPreferences ключи
  static const String keyUserId = 'user_id';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Интервалы повторения в минутах
  // Это алгоритм интервального повторения — ключевая фича Wordly
  static const List<int> reviewIntervals = [
    0, // 1-й повтор: сразу
    20, // 2-й повтор: через 20 минут
    480, // 3-й повтор: через 8 часов
    1440, // 4-й повтор: через 24 часа
    4320, // 5-й повтор: через 3 дня
    10080, // 6-й повтор: через 1 неделю
    20160, // 7-й повтор: через 2 недели
    43200, // 8-й повтор: через 1 месяц (30 дней)
  ];

  static const int maxReviewStage = 8; // максимальный уровень повторения

  // Notification channels
  static const String reviewChannelId = 'wordly_review_channel';
  static const String reviewChannelName = 'Word Reviews';
}
