import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/app_logo.dart';
import 'package:my_project/widgets/auth_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                  const SizedBox(height: AppSpacing.xl),
                  const AppLogo(),
                  const SizedBox(height: AppSpacing.xxl),
                  const Text('Create\naccount.', style: AppText.h1),
                  const SizedBox(height: AppSpacing.xl),
                  const AuthTextField(label: 'Full Name', hint: 'John Doe'),
                  const SizedBox(height: AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.md),
                  const AuthTextField(
                    label: 'Confirm Password',
                    hint: '••••••••',
                    isPassword: true,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Sign Up',
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/home'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Already have an account',
                    isOutlined: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
