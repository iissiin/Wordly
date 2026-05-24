import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../domain/repositories/auth_repository.dart';
import '../injection_container.dart';
import 'auth/cubit/auth_cubit.dart';
import 'router/app_router.dart';

class WordlyApp extends StatefulWidget {
  const WordlyApp({super.key});

  @override
  State<WordlyApp> createState() => _WordlyAppState();
}

class _WordlyAppState extends State<WordlyApp> {
  late final AuthCubit _authCubit;
  late final GoRouterWrapper _routerWrapper;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>();
    _routerWrapper = GoRouterWrapper(_authCubit);

    // Слушаем authStateChanges из Firebase через Repository
    // Это единственное место, где мы подписываемся на поток авторизации
    sl<AuthRepository>().authStateChanges.listen((user) {
      if (user != null) {
        _authCubit.setAuthenticated(user);
      } else {
        _authCubit.setUnauthenticated();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: MaterialApp.router(
        title: 'Wordly',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        routerConfig: _routerWrapper.router,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}

class GoRouterWrapper {
  final AuthCubit authCubit;
  late final router = AppRouter.router(authCubit);

  GoRouterWrapper(this.authCubit);
}
