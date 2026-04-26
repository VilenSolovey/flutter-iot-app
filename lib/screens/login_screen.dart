import 'package:flutter/material.dart';
import 'package:my_project/screens/auth/auth_page_scaffold.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/auth_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.authService,
    required this.connectivityService,
    super.key,
  });

  final AuthService authService;
  final ConnectivityService connectivityService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final hasInternet =
        await widget.connectivityService.hasInternetConnection();
    if (!hasInternet) {
      return _showMessage(
        'Немає інтернету. Увійти можна лише після відновлення мережі.',
      );
    }
    setState(() {
      _isLoading = true;
    });

    final result = await widget.authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    if (result.isSuccess) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }
    _showMessage(result.message ?? 'Помилка входу');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      title: 'Welcome\nback.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthTextField(
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  widget.authService.validateEmail(value?.trim() ?? ''),
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              label: 'Password',
              hint: '••••••••',
              isPassword: true,
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              validator: (value) =>
                  widget.authService.validatePassword(value?.trim() ?? ''),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('Forgot password?', style: AppText.muted),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: _isLoading ? 'Loading...' : 'Sign In',
              onPressed: _isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Create Account',
              isOutlined: true,
              onPressed: () => Navigator.pushNamed(context, '/register'),
            ),
          ],
        ),
      ),
    );
  }
}
