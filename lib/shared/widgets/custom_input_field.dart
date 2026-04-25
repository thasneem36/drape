import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailing;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType keyboardType;

  const CustomInputField({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
    this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.eyebrow),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(color: AppColors.line),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: AppText.bodyM,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.muted) : null,
              suffixIcon: trailing != null ? Icon(trailing, size: 18, color: AppColors.muted) : null,
            ),
          ),
        ),
      ],
    );
  }
}
