// ─────────────────────────────────────────────────────────────
// Signup screen — wired to FirebaseAuth via AuthService.
// Creates auth user + Firestore user doc via signupWithName().
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/primary_button.dart';
import '../shared/widgets/social_buttons.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name    = TextEditingController();
  final _email   = TextEditingController();
  final _pw      = TextEditingController();
  final _confirm = TextEditingController();
  bool _pwVisible      = false;
  bool _confirmVisible = false;
  bool _loading        = false;
  bool _googleLoading  = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose(); _email.dispose();
    _pw.dispose(); _confirm.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      final result = await context.read<AuthService>().signInWithGoogle();
      if (result == null && mounted) setState(() => _googleLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() { _error = AuthService.errorMessage(e); _googleLoading = false; });
      }
    }
  }

  Future<void> _createAccount() async {
    final name  = _name.text.trim();
    final email = _email.text.trim();
    final pw    = _pw.text;
    final conf  = _confirm.text;

    if (name.isEmpty || email.isEmpty || pw.isEmpty || conf.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (pw != conf) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (pw.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthService>().signupWithName(name, email, pw);
      // _AuthGate in app.dart will automatically navigate to HomeScreen
      // once FirebaseAuth emits the signed-in user event.
    } catch (e) {
      if (mounted) setState(() { _error = AuthService.errorMessage(e); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Back ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
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
                    Text('Create account.', style: AppText.displayL),
                    const SizedBox(height: 10),
                    Text('Join Drape and build your wardrobe.',
                        style: AppText.bodyS.copyWith(color: AppColors.muted)),
                    const SizedBox(height: 36),

                    _Field(label: 'FULL NAME', icon: Icons.person_outline, controller: _name),
                    const SizedBox(height: 14),
                    _Field(label: 'EMAIL', icon: Icons.alternate_email, controller: _email,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _PasswordField(
                      label: 'PASSWORD',
                      controller: _pw,
                      visible: _pwVisible,
                      onToggle: () => setState(() => _pwVisible = !_pwVisible),
                    ),
                    const SizedBox(height: 14),
                    _PasswordField(
                      label: 'CONFIRM PASSWORD',
                      controller: _confirm,
                      visible: _confirmVisible,
                      onToggle: () => setState(() => _confirmVisible = !_confirmVisible),
                    ),

                    // ── Error message ──────────────────────────
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.base),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: AppText.caption.copyWith(color: Colors.redAccent)),
                          ),
                        ]),
                      ),
                    ],

                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: _loading ? 'CREATING ACCOUNT…' : 'CREATE ACCOUNT',
                      onTap: _loading ? null : _createAccount,
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
                      Expanded(child: const AppleSignInButton()),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GoogleSignInButton(
                          loading: _googleLoading,
                          onTap: _googleLoading ? null : _signInWithGoogle,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 32),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                        child: RichText(
                          text: TextSpan(
                            style: AppText.bodyS.copyWith(color: AppColors.muted),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign in',
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

}

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  const _Field({
    required this.label, required this.icon, required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Column(
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
                  keyboardType: keyboardType,
                  style: AppText.bodyM,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ]),
          ),
        ],
      );
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;
  const _PasswordField({
    required this.label, required this.controller,
    required this.visible, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Column(
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
              const Icon(Icons.lock_outline, size: 17, color: AppColors.muted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !visible,
                  style: AppText.bodyM,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 16, color: AppColors.muted,
                ),
              ),
            ]),
          ),
        ],
      );
}
