import 'package:wordly/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
  Future<void> updateUserName(String name);
  Future<void> deleteAccount();
}
