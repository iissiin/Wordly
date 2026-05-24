import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordly/domain/entities/quiz_settings.dart';
import '../../domain/entities/dictionary.dart';
import '../../injection_container.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import '../auth/screens/login_screen.dart';
import '../home/cubit/home_cubit.dart';
import '../home/screens/home_screen.dart';
import '../dictionary/cubit/dictionary_cubit.dart';
import '../dictionary/screens/dictionary_screen.dart';
import '../dictionary/screens/dictionary_form_screen.dart';
import '../profile/cubit/profile_cubit.dart';
import '../profile/screens/profile_screen.dart';
import '../quiz/cubit/quiz_cubit.dart';
import '../quiz/screens/flashcard_screen.dart';
import '../quiz/screens/written_screen.dart';
import '../quiz/screens/quiz_result_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/';
  static const String dictionary = '/dictionary';
  static const String dictionaryNew = '/dictionary/new';
  static const String dictionaryEdit = '/dictionary/edit';
  static const String flashCards = '/quiz/flashcards';
  static const String written = '/quiz/written';
  static const String quizResult = '/quiz/result';
  static const String profile = '/profile';

  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: home,
      refreshListenable: _AuthNotifier(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;
        final isLoggedIn = authState is AuthAuthenticated;
        final isOnLogin = state.matchedLocation == login;

        if (!isLoggedIn && !isOnLogin) return login;
        if (isLoggedIn && isOnLogin) return home;
        return null;
      },
      routes: [
        // ── Login ──────────────────────────────────────────
        GoRoute(
          path: login,
          builder: (_, __) => BlocProvider.value(
            value: authCubit,
            child: const LoginScreen(),
          ),
        ),

        // ── Home ───────────────────────────────────────────
        GoRoute(
          path: home,
          builder: (_, __) => BlocProvider(
            create: (_) => sl<HomeCubit>(),
            child: const HomeScreen(),
          ),
          routes: [
            // ── Profile ─────────────────────────────────
            GoRoute(
              path: 'profile',
              builder: (_, __) => BlocProvider(
                create: (_) => sl<ProfileCubit>(),
                child: const ProfileScreen(),
              ),
            ),

            // ── New Dictionary ──────────────────────────
            GoRoute(
              path: 'dictionary/new',
              builder: (_, __) => BlocProvider(
                create: (_) => sl<DictionaryCubit>(),
                child: const DictionaryFormScreen(),
              ),
            ),

            // ── Dictionary Detail ───────────────────────
            GoRoute(
              path: 'dictionary/:id',
              builder: (_, state) {
                final dictionary = state.extra as Dictionary;
                return BlocProvider(
                  create: (_) => sl<DictionaryCubit>(),
                  child: DictionaryScreen(
                    dictionary: dictionary,
                  ),
                );
              },
              routes: [
                // ── Edit Dictionary ─────────────────
                GoRoute(
                  path: 'edit',
                  builder: (_, state) {
                    final dictionary = state.extra as Dictionary;
                    return BlocProvider(
                      create: (_) => sl<DictionaryCubit>(),
                      child: DictionaryFormScreen(
                        dictionary: dictionary,
                      ),
                    );
                  },
                ),

                // ── Flashcards ──────────────────────
                GoRoute(
                  path: 'flashcards',
                  builder: (_, state) {
                    final args = state.extra as Map<String, dynamic>;
                    return BlocProvider(
                      create: (_) => sl<QuizCubit>(),
                      child: FlashCardScreen(
                        dictionary: args['dictionary'] as Dictionary,
                        settings: args['settings'] as QuizSettings,
                      ),
                    );
                  },
                ),

                // ── Written Input ───────────────────
                GoRoute(
                  path: 'written',
                  builder: (_, state) {
                    final args = state.extra as Map<String, dynamic>;
                    return BlocProvider(
                      create: (_) => sl<QuizCubit>(),
                      child: WrittenScreen(
                        dictionary: args['dictionary'] as Dictionary,
                        settings: args['settings'] as QuizSettings,
                      ),
                    );
                  },
                ),

                // ── Quiz Result ─────────────────────
                GoRoute(
                  path: 'result',
                  builder: (_, state) {
                    final args = state.extra as Map<String, dynamic>;
                    return QuizResultScreen(
                      correct: args['correct'] as int,
                      total: args['total'] as int,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Нотификатор для GoRouter — реагирует на изменения AuthState
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Stream stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
