import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isOutlined ? _outlined() : _filled(),
    );
  }

  Widget _filled() => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      );

  Widget _outlined() => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      );
}
