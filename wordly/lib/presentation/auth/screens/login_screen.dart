import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),

                  // ── App name ──────────────────────────
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 36,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn words.\nReview. Remember.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 4),

                  // ── Divider ───────────────────────────
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 24),

                  // ── Sign in button ────────────────────
                  const Text(
                    AppStrings.signInSubtitle,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),

                  AppButton(
                    label: AppStrings.signInWithGoogle,
                    icon: Icons.login,
                    isLoading: isLoading,
                    width: double.infinity,
                    onPressed: () =>
                        context.read<AuthCubit>().signInWithGoogle(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
