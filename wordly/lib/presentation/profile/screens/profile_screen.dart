import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../domain/entities/user.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Name updated')),
            );
          }
          if (state is ProfileOperationSuccess) {
            if (state.message == 'Signed out' ||
                state.message == 'Account deleted') {
              context.go('/');
              return;
            }
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          final user = (state is ProfileLoaded)
              ? state.user
              : (state is ProfileUpdated)
                  ? state.user
                  : null;

          if (user == null) return const SizedBox.shrink();

          return _ProfileBody(user: user);
        },
      ),
    );
  }
}

// ─── Profile Body ──────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  final AppUser user;

  const _ProfileBody({required this.user});

  static const double _dividerInset = 56;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // ── User info ───────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text(user.email, style: AppTextStyles.caption),
            ],
          ),
        ),

        const SizedBox(height: 8),
        const Divider(height: 1),

        // ── Edit name ───────────────────────────────
        ListTile(
          leading: const Icon(Icons.edit_outlined,
              color: AppColors.textSecondary, size: 20),
          title:
              const Text(AppStrings.editName, style: TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right,
              color: AppColors.textHint, size: 20),
          onTap: () => _showEditNameSheet(context, user.name),
        ),

        const Divider(height: 1, indent: _dividerInset),

        // ── Sign out ────────────────────────────────
        ListTile(
          leading: const Icon(Icons.logout,
              color: AppColors.textSecondary, size: 20),
          title: const Text(AppStrings.signOut, style: TextStyle(fontSize: 15)),
          onTap: () => _confirmSignOut(context),
        ),

        const Divider(height: 1, indent: _dividerInset),

        // ── Delete account ──────────────────────────
        ListTile(
          leading: const Icon(Icons.delete_forever_outlined,
              color: AppColors.error, size: 20),
          title: const Text(
            AppStrings.deleteAccount,
            style: TextStyle(fontSize: 15, color: AppColors.error),
          ),
          onTap: () => _confirmDeleteAccount(context),
        ),
      ],
    );
  }

  // ─── Edit Name Sheet ─────────────────────────────

  void _showEditNameSheet(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(AppStrings.editName, style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'Your name',
                counterText: '',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: AppStrings.save,
              width: double.infinity,
              onPressed: () {
                Navigator.pop(sheetContext);
                context.read<ProfileCubit>().updateName(controller.text);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sign out ─────────────────────────────────────

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.signOut),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileCubit>().signOut();
            },
            child: const Text(AppStrings.signOut),
          ),
        ],
      ),
    );
  }

  // ─── Delete account ──────────────────────────────

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.deleteAccount),
        content: const Text(AppStrings.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileCubit>().deleteAccount();
            },
            child: const Text(
              AppStrings.deleteAccount,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
