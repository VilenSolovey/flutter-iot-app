import 'package:flutter/material.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/screens/profile/profile_header.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/auth_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';
import 'package:my_project/widgets/section_header.dart';
import 'package:my_project/widgets/stat_card.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    required this.user,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.isSaving,
    required this.onSave,
    required this.onLogout,
    required this.onDelete,
    required this.nameValidator,
    required this.emailValidator,
    super.key,
  });

  final UserProfile user;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onLogout;
  final VoidCallback onDelete;
  final FormFieldValidator<String> nameValidator;
  final FormFieldValidator<String> emailValidator;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: AppSpacing.xl),
                const Row(
                  children: [
                    StatCard(value: '99%', label: 'UPTIME'),
                    SizedBox(width: AppSpacing.sm),
                    StatCard(value: '1', label: 'USER'),
                    SizedBox(width: AppSpacing.sm),
                    StatCard(value: 'CACHE', label: 'OFFLINE'),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Edit Profile'),
                const SizedBox(height: AppSpacing.md),
                AuthTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  validator: nameValidator,
                ),
                const SizedBox(height: AppSpacing.md),
                AuthTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  textInputAction: TextInputAction.done,
                  validator: emailValidator,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: isSaving ? 'Saving...' : 'Save Changes',
                  onPressed: isSaving ? null : onSave,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Logout',
                  isOutlined: true,
                  onPressed: onLogout,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Delete Account',
                  isOutlined: true,
                  onPressed: onDelete,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}
