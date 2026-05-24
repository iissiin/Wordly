import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/dictionary/get_dictionaries.dart';
import '../../../injection_container.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetDictionaries _getDictionaries;
  StreamSubscription? _subscription;

  HomeCubit({required GetDictionaries getDictionaries})
      : _getDictionaries = getDictionaries,
        super(const HomeInitial());

  void loadDictionaries() {
    final user = sl<AuthRepository>().currentUser;
    if (user == null) return;

    emit(const HomeLoading());
    _subscription?.cancel();

    _subscription = _getDictionaries(user.id).listen(
      (dictionaries) => emit(HomeLoaded(dictionaries)),
      onError: (e) => emit(HomeError(e.toString())),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
