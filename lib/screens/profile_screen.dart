import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/screens/profile/profile_content.dart';
import 'package:my_project/state/profile/profile_cubit.dart';
import 'package:my_project/state/profile/profile_state.dart';
import 'package:my_project/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = context.read<ProfileCubit>().state.user;
    if (user == null || !(_formKey.currentState?.validate() ?? false)) return;
    await context.read<ProfileCubit>().saveProfile(
          oldUser: user,
          fullName: _nameController.text,
          email: _emailController.text,
        );
  }

  Future<void> _logout() async {
    final shouldLogout = await _confirm(
      title: 'Logout',
      content: 'Вийти з акаунта? Активну сесію буде завершено.',
      action: 'Logout',
    );
    if (shouldLogout == true && mounted) {
      await context.read<ProfileCubit>().logout();
    }
  }

  Future<void> _deleteAccount() async {
    final shouldDelete = await _confirm(
      title: 'Delete account',
      content: 'Видалити користувача і всі локальні записи?',
      action: 'Delete',
    );
    if (shouldDelete == true && mounted) {
      await context.read<ProfileCubit>().deleteAccount();
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String content,
    required String action,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppText.h2),
        content: Text(content, style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _syncControllers(ProfileState state) {
    final user = state.user;
    if (user == null) return;
    if (_nameController.text != user.fullName) {
      _nameController.text = user.fullName;
    }
    if (_emailController.text != user.email) {
      _emailController.text = user.email;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.shouldOpenLogin) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          return;
        }
        _syncControllers(state);
        if (state.message != null) _showMessage(state.message!);
      },
      builder: (context, state) {
        final user = state.user;
        if (state.isLoading || user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        _syncControllers(state);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Profile', style: AppText.h2),
          ),
          body: ProfileContent(
            user: user,
            formKey: _formKey,
            nameController: _nameController,
            emailController: _emailController,
            isSaving: state.isSaving,
            onSave: _saveProfile,
            onLogout: _logout,
            onDelete: _deleteAccount,
            nameValidator: (value) => context
                .read<ProfileCubit>()
                .validateFullName(value?.trim() ?? ''),
            emailValidator: (value) =>
                context.read<ProfileCubit>().validateEmail(value?.trim() ?? ''),
          ),
        );
      },
    );
  }
}
