import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wordly/domain/usecases/dictionary/watch_dictionary.dart';

import 'facade/firebase_facade.dart';
import 'facade/firebase_facade_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/dictionary_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/dictionary_repository.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/usecases/auth/sign_in_with_google.dart';
import 'domain/usecases/auth/sign_out.dart';
import 'domain/usecases/dictionary/get_dictionaries.dart';
import 'domain/usecases/dictionary/create_dictionary.dart';
import 'domain/usecases/dictionary/update_dictionary.dart';
import 'domain/usecases/dictionary/delete_dictionary.dart';
import 'domain/usecases/word/mark_word_reviewed.dart';
import 'presentation/auth/cubit/auth_cubit.dart';
import 'presentation/home/cubit/home_cubit.dart';
import 'presentation/dictionary/cubit/dictionary_cubit.dart';
import 'presentation/profile/cubit/profile_cubit.dart';
import 'presentation/quiz/cubit/quiz_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── External ─────────────────────────────────────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(
    () => GoogleSignIn(scopes: ['email', 'profile']),
  );

  // ─── Facade ───────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseFacade>(
    () => FirebaseFacadeImpl(
      auth: sl(),
      firestore: sl(),
      messaging: sl(),
      storage: sl(),
      googleSignIn: sl(),
    ),
  );

  // ─── Repositories ─────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(facade: sl()),
  );
  sl.registerLazySingleton<DictionaryRepository>(
    () => DictionaryRepositoryImpl(facade: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(facade: sl()),
  );

  // ─── Use Cases ────────────────────────────────────────────
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetDictionaries(sl()));
  sl.registerLazySingleton(() => CreateDictionary(sl()));
  sl.registerLazySingleton(() => UpdateDictionary(sl()));
  sl.registerLazySingleton(() => DeleteDictionary(sl()));
  sl.registerLazySingleton(() => MarkWordReviewed(sl()));

  // ─── Cubits ───────────────────────────────────────────────
  sl.registerFactory(
    () => AuthCubit(signInWithGoogle: sl(), signOut: sl()),
  );
  sl.registerFactory(
    () => HomeCubit(getDictionaries: sl()),
  );
  sl.registerFactory(
    () => DictionaryCubit(
      createDictionary: sl(),
      updateDictionary: sl(),
      deleteDictionary: sl(),
      markWordReviewed: sl(),
      watchDictionary: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileCubit(authRepository: sl()),
  );
  sl.registerFactory(() => QuizCubit());

  sl.registerLazySingleton(() => WatchDictionary(sl()));
}
