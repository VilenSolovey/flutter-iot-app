import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/screens/auth/auth_page_scaffold.dart';
import 'package:my_project/state/auth/auth_cubit.dart';
import 'package:my_project/state/auth/auth_state.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/auth_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<AuthCubit>().register(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
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
          title: 'Create\naccount.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) => context
                      .read<AuthCubit>()
                      .validateFullName(value?.trim() ?? ''),
                ),
                const SizedBox(height: AppSpacing.md),
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
                  textInputAction: TextInputAction.next,
                  validator: (value) => context
                      .read<AuthCubit>()
                      .validatePassword(value?.trim() ?? ''),
                ),
                const SizedBox(height: AppSpacing.md),
                AuthTextField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  isPassword: true,
                  controller: _confirmController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  validator: (value) =>
                      context.read<AuthCubit>().validateConfirmPassword(
                            _passwordController.text,
                            value?.trim() ?? '',
                          ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: state.isLoading ? 'Loading...' : 'Sign Up',
                  onPressed: state.isLoading ? null : _handleRegister,
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
          ),
        );
      },
    );
  }
}
