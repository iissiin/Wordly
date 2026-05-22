import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../facade/firebase_facade.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseFacade _facade;

  AuthRepositoryImpl(this._facade);

  @override
  UserEntity? get currentUser => _facade.currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => _facade.authStateChanges;

  @override
  Future<UserEntity> signInWithGoogle() => _facade.signInWithGoogle();

  @override
  Future<void> signOut() => _facade.signOut();

  @override
  Future<void> deleteAccount() async {
    // TODO: реализовать удаление аккаунта
    await _facade.signOut();
  }
}
