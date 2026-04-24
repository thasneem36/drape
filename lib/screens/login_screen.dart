// ─────────────────────────────────────────────────────────────
// Login screen.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../core/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(text: 'sarah@email.com');
  final pw = TextEditingController(text: 'password');

  @override
  void dispose() { email.dispose(); pw.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: AppColors.ink),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 10, 26, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back.', style: AppText.displayL),
                    const SizedBox(height: 10),
                    Text('Sign in to continue your edit.',
                        style: AppText.bodyS.copyWith(color: AppColors.muted)),
                    const SizedBox(height: 36),
                    _Field(label: 'EMAIL', icon: Icons.alternate_email, controller: email),
                    const SizedBox(height: 14),
                    _Field(label: 'PASSWORD', icon: Icons.lock_outline, controller: pw, obscure: true, trailing: Icons.visibility_outlined),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Forgot password?', style: AppText.caption.copyWith(
                        color: AppColors.accentInk,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'SIGN IN',
                      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                    ),
                    const SizedBox(height: 28),
                    Row(children: [
                      const Expanded(child: Divider(color: AppColors.line)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR CONTINUE WITH', style: AppText.eyebrow),
                      ),
                      const Expanded(child: Divider(color: AppColors.line)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _socialBtn('Apple')),
                      const SizedBox(width: 10),
                      Expanded(child: _socialBtn('Google')),
                    ]),
                    const SizedBox(height: 32),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: AppText.bodyS.copyWith(color: AppColors.muted),
                          children: [
                            const TextSpan(text: 'New to Drape? '),
                            TextSpan(
                              text: 'Create account',
                              style: AppText.bodyS.copyWith(
                                color: AppColors.accentInk,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialBtn(String label) => Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.base),
          border: Border.all(color: AppColors.lineStrong),
        ),
        child: Text(label, style: AppText.label.copyWith(fontSize: 12.5)),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final IconData? trailing;
  const _Field({required this.label, required this.icon, required this.controller, this.obscure = false, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.eyebrow.copyWith(color: AppColors.muted)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(color: AppColors.line),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Icon(icon, size: 17, color: AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                style: AppText.bodyM,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (trailing != null) Icon(trailing, size: 16, color: AppColors.muted),
          ]),
        ),
      ],
    );
  }
}
