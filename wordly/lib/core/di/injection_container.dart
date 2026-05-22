// lib/core/di/injection_container.dart
// Dependency Injection — внедрение зависимостей.
// get_it работает как глобальный реестр объектов.
// Мы регистрируем объекты один раз при старте приложения,
// а потом получаем их из любого места через sl<Тип>().

import 'package:get_it/get_it.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/pack_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/repositories/word_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/pack_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/repositories/word_repository.dart';
import '../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/pack/create_pack_usecase.dart';
import '../../domain/usecases/pack/watch_packs_usecase.dart';
import '../../domain/usecases/review/submit_review_usecase.dart';
import '../../domain/usecases/word/add_word_usecase.dart';
import '../../domain/usecases/word/get_due_words_usecase.dart';
import '../../facade/firebase_facade.dart';

// sl = Service Locator — стандартное название
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── 1. Facade (синглтон — один на всё приложение) ────────
  sl.registerLazySingleton<FirebaseFacade>(() => FirebaseFacade());

  // ── 2. Repositories ──────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PackRepository>(
    () => PackRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WordRepository>(
    () => WordRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl()),
  );

  // ── 3. Use Cases ─────────────────────────────────────────
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => CreatePackUseCase(sl()));
  sl.registerLazySingleton(() => WatchPacksUseCase(sl()));
  sl.registerLazySingleton(() => AddWordUseCase(sl()));
  sl.registerLazySingleton(() => GetDueWordsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl()));
}
