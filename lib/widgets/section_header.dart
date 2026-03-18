import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.h2),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: AppText.muted.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColors.secondary,
              ),
            ),
          ),
      ],
    );
  }
}
