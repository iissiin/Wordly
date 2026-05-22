import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class SignInWithGoogleUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  @override
  Future<UserEntity> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}
