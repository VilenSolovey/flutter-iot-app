import 'package:flutter/material.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/screens/profile/profile_content.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:my_project/theme/app_theme.dart';

part 'profile/profile_actions.dart';

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
    if (!mounted) return;
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
    if (user == null || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    final result = await widget.authService.updateProfile(
      oldUser: user,
      fullName: _nameController.text,
      email: _emailController.text,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _user = result.user ?? _user;
    });
    _showMessage(result.message ?? 'Помилка оновлення профілю');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (_isLoading || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
        isSaving: _isSaving,
        onSave: _saveProfile,
        onLogout: _logout,
        onDelete: _deleteAccount,
        nameValidator: (value) =>
            widget.authService.validateFullName(value ?? ''),
        emailValidator: (value) =>
            widget.authService.validateEmail(value ?? ''),
      ),
    );
  }
}
