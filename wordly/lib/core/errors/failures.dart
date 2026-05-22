import 'package:equatable/equatable.dart';

// Базовый класс ошибки
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Ошибки авторизации
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Ошибки сети/Firestore
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Ошибки локального хранения
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Ошибки валидации
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
