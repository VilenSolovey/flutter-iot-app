import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'V',
              style: TextStyle(
                color: AppColors.bg,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'VITA',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}
