import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<void> call(NoParams params) {
    return _repository.signOut();
  }
}
