import 'package:wordly/domain/repositories/auth_repository.dart';

import '../../domain/entities/user.dart';
import '../../facade/firebase_facade.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseFacade _facade;

  AuthRepositoryImpl({required FirebaseFacade facade}) : _facade = facade;

  @override
  Stream<AppUser?> get authStateChanges {
    return _facade.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      // Получаем или создаём данные пользователя в Firestore
      final data = await _facade.getUserData(firebaseUser.uid);
      if (data != null) {
        return UserModel.fromMap({...data, 'id': firebaseUser.uid});
      }

      // Первый вход — создаём документ
      final newUser = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
      );
      await _facade.setUserData(
        userId: firebaseUser.uid,
        data: newUser.toMap(),
      );
      return newUser;
    });
  }

  @override
  AppUser? get currentUser {
    final user = _facade.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
    );
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final credential = await _facade.signInWithGoogle();
    final firebaseUser = credential.user!;

    final existingData = await _facade.getUserData(firebaseUser.uid);
    if (existingData != null) {
      return UserModel.fromMap({
        ...existingData,
        'id': firebaseUser.uid,
      });
    }

    final newUser = UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
    );
    await _facade.setUserData(
      userId: firebaseUser.uid,
      data: newUser.toMap(),
    );
    return newUser;
  }

  @override
  Future<void> signOut() => _facade.signOut();

  @override
  Future<void> updateUserName(String name) async {
    final user = _facade.currentUser;
    if (user == null) return;
    await _facade.updateUserData(
      userId: user.uid,
      data: {'name': name},
    );
  }

  @override
  Future<void> deleteAccount() => _facade.deleteAccount();
}
