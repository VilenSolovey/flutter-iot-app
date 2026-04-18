import 'package:flutter/material.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/auth_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';
import 'package:my_project/widgets/section_header.dart';
import 'package:my_project/widgets/stat_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.authService,
    required this.healthRecordService,
    super.key,
  });

  final AuthService authService;
  final HealthRecordService healthRecordService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  UserProfile? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await widget.authService.getActiveUser();
    if (!mounted) {
      return;
    }
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _user = user;
      _nameController.text = user.fullName;
      _emailController.text = user.email;
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    final user = _user;
    if (user == null) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final result = await widget.authService.updateProfile(
      oldUser: user,
      fullName: _nameController.text,
      email: _emailController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      _user = result.user ?? _user;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Помилка оновлення профілю'),
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Logout', style: AppText.h2),
        content: const Text(
          'Вийти з акаунта? Активну сесію буде завершено.',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }

    await widget.authService.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _deleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete account', style: AppText.h2),
        content: const Text(
          'Видалити користувача і всі локальні записи?',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    await widget.authService.deleteUser();
    await widget.healthRecordService.clearAllRecords();

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No profile data')),
      );
    }

    final avatarText = user.fullName.isNotEmpty
        ? user.fullName.substring(0, 1).toUpperCase()
        : 'U';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = constraints.maxWidth > 600
              ? constraints.maxWidth * 0.15
              : AppSpacing.lg;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: AppSpacing.md,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    fullName: user.fullName,
                    email: user.email,
                    avatarText: avatarText,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _StatsRow(),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Edit Profile'),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    label: 'Full Name',
                    hint: 'John Doe',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        widget.authService.validateFullName(value ?? ''),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    textInputAction: TextInputAction.done,
                    validator: (value) =>
                        widget.authService.validateEmail(value ?? ''),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: _isSaving ? 'Saving...' : 'Save Changes',
                    onPressed: _isSaving ? null : _saveProfile,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Logout',
                    isOutlined: true,
                    onPressed: _logout,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Delete Account',
                    isOutlined: true,
                    onPressed: _deleteAccount,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.email,
    required this.avatarText,
  });

  final String fullName;
  final String email;
  final String avatarText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Hero(
          tag: 'profile-avatar',
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Center(
              child: Text(
                avatarText,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName, style: AppText.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(email, style: AppText.muted),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        StatCard(value: '99%', label: 'UPTIME'),
        SizedBox(width: AppSpacing.sm),
        StatCard(value: '1', label: 'USER'),
        SizedBox(width: AppSpacing.sm),
        StatCard(value: 'LOCAL', label: 'STORAGE'),
      ],
    );
  }
}
