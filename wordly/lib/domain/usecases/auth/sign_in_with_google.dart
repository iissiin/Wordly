import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository _repository;
  SignInWithGoogle(this._repository);

  Future<AppUser> call() => _repository.signInWithGoogle();
}
