import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;

  ProfileCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const ProfileInitial());

  void loadProfile() {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(const ProfileError('User not found'));
      return;
    }
    emit(ProfileLoaded(user));
  }

  Future<void> updateName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    emit(const ProfileLoading());
    try {
      await _authRepository.updateUserName(trimmed);
      final user = _authRepository.currentUser;
      if (user != null) {
        emit(ProfileLoaded(user));
      }
      emit(const ProfileOperationSuccess('Name updated'));
    } on Exception catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const ProfileLoading());
    try {
      await _authRepository.signOut();
      emit(const ProfileOperationSuccess('Signed out'));
    } on Exception catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    emit(const ProfileLoading());
    try {
      await _authRepository.deleteAccount();
      emit(const ProfileOperationSuccess('Account deleted'));
    } on Exception catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
