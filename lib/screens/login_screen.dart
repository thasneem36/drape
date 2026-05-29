// ─────────────────────────────────────────────────────────────
// Login screen — wired to FirebaseAuth via AuthService.
// ─────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/primary_button.dart';
import '../shared/widgets/social_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pw    = TextEditingController();
  bool _loading       = false;
  bool _googleLoading = false;
  bool _pwVisible     = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      final result = await context.read<AuthService>().signInWithGoogle();
      if (result == null && mounted) {
        // User cancelled the picker — not an error
        setState(() => _googleLoading = false);
      }
      // On success _AuthGate handles navigation automatically
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AuthService.errorMessage(e);
          _googleLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    // Pre-fill the sheet's field with whatever is already typed.
    final prefill = _email.text.trim();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ForgotPasswordSheet(prefillEmail: prefill),
    );
  }

  Future<void> _signIn() async {
    final emailVal = _email.text.trim();
    final pwVal    = _pw.text;
    if (emailVal.isEmpty || pwVal.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthService>().login(emailVal, pwVal);
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
                    _Field(label: 'EMAIL', icon: Icons.alternate_email, controller: _email,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _PasswordField(
                      controller: _pw,
                      visible: _pwVisible,
                      onToggle: () => setState(() => _pwVisible = !_pwVisible),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _forgotPassword,
                        child: Text('Forgot password?',
                            style: AppText.caption.copyWith(
                              color: AppColors.accentInk,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
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
                      label: _loading ? 'SIGNING IN…' : 'SIGN IN',
                      onTap: _loading ? null : _signIn,
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
                        onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
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


// ── Forgot Password Sheet ─────────────────────────────────────

class _ForgotPasswordSheet extends StatefulWidget {
  final String prefillEmail;
  const _ForgotPasswordSheet({this.prefillEmail = ''});

  @override
  State<_ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState
    extends State<_ForgotPasswordSheet> {
  late final TextEditingController _emailCtrl;
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.prefillEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);
      if (mounted) setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = AuthService.errorMessage(e);
          _sending = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Something went wrong. Please try again.';
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          if (_sent) ...[
            // ── Success state ──────────────────────────────
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    size: 28, color: Color(0xFF4CAF50)),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text('Check your inbox',
                  style: AppText.titleS.copyWith(
                      fontWeight: FontWeight.w600, fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'A reset link has been sent to\n${_emailCtrl.text.trim()}',
                style:
                    AppText.bodyS.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'DONE',
              onTap: () => Navigator.pop(context),
            ),
          ] else ...[
            // ── Form state ────────────────────────────────
            Text('Reset Password',
                style: AppText.titleS.copyWith(
                    fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'Enter your email and we\'ll send a reset link.',
              style: AppText.bodyS.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 24),

            // Email field
            Text('EMAIL',
                style:
                    AppText.eyebrow.copyWith(color: AppColors.muted)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppRadius.base),
                border: Border.all(color: AppColors.line),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppText.bodyS,
                decoration: InputDecoration(
                  hintText: 'your@email.com',
                  hintStyle:
                      AppText.bodyS.copyWith(color: AppColors.muted),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: AppText.caption
                      .copyWith(color: Colors.redAccent)),
            ],

            const SizedBox(height: 24),
            PrimaryButton(
              label: _sending ? 'SENDING…' : 'SEND RESET LINK',
              icon: _sending ? null : Icons.send_outlined,
              onTap: _sending ? null : _send,
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Text Field ────────────────────────────────────────────────

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
}

// ── Password Field (with show/hide toggle) ────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;
  const _PasswordField({
    required this.controller,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PASSWORD',
              style: AppText.eyebrow.copyWith(color: AppColors.muted)),
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
                  visible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.muted,
                ),
              ),
            ]),
          ),
        ],
      );
}
