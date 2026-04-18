import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/app_logo.dart';

class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

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
                  Text(title, style: AppText.h1),
                  const SizedBox(height: AppSpacing.xl),
                  child,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
