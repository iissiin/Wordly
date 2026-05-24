import 'package:firebase_auth/firebase_auth.dart';

/// FirebaseFacade — единая точка доступа ко всем Firebase сервисам.
///
/// Паттерн Facade скрывает сложность подсистемы (Firebase SDK)
/// за простым интерфейсом. Репозитории работают только с этим
/// интерфейсом — они не знают, Firebase это, Mock или другой backend.
abstract class FirebaseFacade {
  // ─── AUTH ────────────────────────────────────────────────

  /// Текущий авторизованный пользователь
  User? get currentUser;

  /// Stream изменений состояния авторизации
  Stream<User?> get authStateChanges;

  /// Войти через Google
  Future<UserCredential> signInWithGoogle();

  /// Выйти из аккаунта
  Future<void> signOut();

  /// Удалить аккаунт текущего пользователя
  Future<void> deleteAccount();

  // ─── FIRESTORE — USER ────────────────────────────────────

  /// Создать или обновить документ пользователя
  Future<void> setUserData({
    required String userId,
    required Map<String, dynamic> data,
  });

  /// Получить данные пользователя
  Future<Map<String, dynamic>?> getUserData(String userId);

  /// Обновить отдельные поля пользователя
  Future<void> updateUserData({
    required String userId,
    required Map<String, dynamic> data,
  });

  // ─── FIRESTORE — DICTIONARIES ────────────────────────────

  /// Stream списка словарей пользователя
  Stream<List<Map<String, dynamic>>> watchDictionaries(String userId);

  /// Получить один словарь
  Future<Map<String, dynamic>?> getDictionary({
    required String userId,
    required String dictionaryId,
  });

  /// Создать словарь
  Future<String> createDictionary({
    required String userId,
    required Map<String, dynamic> data,
  });

  /// Обновить словарь
  Future<void> updateDictionary({
    required String userId,
    required String dictionaryId,
    required Map<String, dynamic> data,
  });

  /// Удалить словарь и все его слова
  Future<void> deleteDictionary({
    required String userId,
    required String dictionaryId,
  });

  // ─── FIRESTORE — WORDS ───────────────────────────────────

  /// Stream слов словаря
  Stream<List<Map<String, dynamic>>> watchWords({
    required String userId,
    required String dictionaryId,
  });

  /// Создать слово
  Future<String> createWord({
    required String userId,
    required String dictionaryId,
    required Map<String, dynamic> data,
  });

  /// Обновить слово
  Future<void> updateWord({
    required String userId,
    required String dictionaryId,
    required String wordId,
    required Map<String, dynamic> data,
  });

  /// Удалить слово
  Future<void> deleteWord({
    required String userId,
    required String dictionaryId,
    required String wordId,
  });

  /// Batch создание слов
  Future<void> createWordsBatch({
    required String userId,
    required String dictionaryId,
    required List<Map<String, dynamic>> words,
  });

  /// Batch удаление слов
  Future<void> deleteWordsBatch({
    required String userId,
    required String dictionaryId,
    required List<String> wordIds,
  });

  // ─── MESSAGING ───────────────────────────────────────────

  /// Получить FCM токен устройства
  Future<String?> getFCMToken();

  /// Запросить разрешение на уведомления
  Future<void> requestNotificationPermission();

  /// Сохранить FCM токен в Firestore
  Future<void> saveFCMToken({
    required String userId,
    required String token,
  });
}
