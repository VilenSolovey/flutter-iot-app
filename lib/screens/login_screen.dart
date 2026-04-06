import 'package:flutter/material.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/app_logo.dart';
import 'package:my_project/widgets/auth_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.authService,
    super.key,
  });

  final AuthService authService;

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
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await widget.authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Помилка входу'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hPad = constraints.maxWidth > 600
                ? constraints.maxWidth * 0.2
                : AppSpacing.lg;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: AppSpacing.lg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    const AppLogo(),
                    const SizedBox(height: AppSpacing.xxl),
                    const Text('Welcome\nback.', style: AppText.h1),
                    const SizedBox(height: AppSpacing.xl),
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
                      validator: (value) => widget.authService
                          .validatePassword(value?.trim() ?? ''),
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
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
