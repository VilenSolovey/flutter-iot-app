import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/screens/auth/auth_page_scaffold.dart';
import 'package:my_project/state/auth/auth_cubit.dart';
import 'package:my_project/state/auth/auth_state.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/auth_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<AuthCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
          return;
        }
        if (state.message != null) _showMessage(state.message!);
      },
      builder: (context, state) {
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
                  validator: (value) => context
                      .read<AuthCubit>()
                      .validateEmail(value?.trim() ?? ''),
                ),
                const SizedBox(height: AppSpacing.md),
                AuthTextField(
                  label: 'Password',
                  hint: '••••••••',
                  isPassword: true,
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  validator: (value) => context
                      .read<AuthCubit>()
                      .validatePassword(value?.trim() ?? ''),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Forgot password?', style: AppText.muted),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: state.isLoading ? 'Loading...' : 'Sign In',
                  onPressed: state.isLoading ? null : _handleLogin,
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
      },
    );
  }
}
