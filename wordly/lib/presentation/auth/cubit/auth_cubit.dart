import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth/sign_in_with_google.dart';
import '../../../domain/usecases/auth/sign_out.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  AuthCubit({
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
  })  : _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        super(const AuthInitial());

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final user = await _signInWithGoogle();
      emit(AuthAuthenticated(user));
    } on Exception catch (e) {
      final message = e.toString();
      // Пользователь закрыл окно — не показываем ошибку
      if (message.contains('cancelled')) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthError(message));
      }
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await _signOut();
      emit(const AuthUnauthenticated());
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void setAuthenticated(user) => emit(AuthAuthenticated(user));
  void setUnauthenticated() => emit(const AuthUnauthenticated());
}
