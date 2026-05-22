import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Текущий пользователь (null если не авторизован)
  UserEntity? get currentUser;

  // Поток изменений авторизации (вошёл/вышел)
  Stream<UserEntity?> get authStateChanges;

  // Войти через Google
  Future<UserEntity> signInWithGoogle();

  // Выйти
  Future<void> signOut();

  // Удалить аккаунт
  Future<void> deleteAccount();
}
