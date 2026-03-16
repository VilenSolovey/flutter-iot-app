import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  const AppLogo(),
                  const SizedBox(height: AppSpacing.xxl),
                  const Text('Welcome\nback.', style: AppText.h1),
                  const SizedBox(height: AppSpacing.xl),
                  const AuthTextField(
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AuthTextField(
                    label: 'Password',
                    hint: '••••••••',
                    isPassword: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Forgot password?', style: AppText.muted),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Sign In',
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/home'),
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
            );
          },
        ),
      ),
    );
  }
}
