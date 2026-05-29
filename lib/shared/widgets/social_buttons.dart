// ─────────────────────────────────────────────────────────────
// Social sign-in buttons — shared by LoginScreen + SignupScreen.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;
  const GoogleSignInButton({super.key, required this.loading, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(color: AppColors.lineStrong),
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google "G" badge
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4285F4),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'G',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Google',
                        style: AppText.label.copyWith(fontSize: 12.5)),
                  ],
                ),
        ),
      );
}

class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AppleSignInButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(color: AppColors.lineStrong),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.apple, size: 18, color: AppColors.ink),
              const SizedBox(width: 6),
              Text('Apple',
                  style: AppText.label.copyWith(fontSize: 12.5)),
            ],
          ),
        ),
      );
}
