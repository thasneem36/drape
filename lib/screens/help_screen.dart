// ─────────────────────────────────────────────────────────────
// Help & Support — FAQ accordion, contact info, app version.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    _FAQ(
      'How do I track my order?',
      'Once your order ships you\'ll receive a confirmation with '
          'tracking details. You can also view live order status in '
          'the Orders section of your profile.',
    ),
    _FAQ(
      'What is your return policy?',
      'We accept returns within 30 days of delivery for items in '
          'their original, unworn condition with tags attached. '
          'Sale items are final sale.',
    ),
    _FAQ(
      'How do I change or cancel my order?',
      'Orders can be modified or cancelled within 1 hour of being '
          'placed. After that, contact our support team and we\'ll '
          'do our best to help.',
    ),
    _FAQ(
      'Do you offer international shipping?',
      'Yes — we ship to over 50 countries. Duties and taxes may '
          'apply and are the responsibility of the recipient.',
    ),
    _FAQ(
      'How do I care for my garments?',
      'Care instructions are printed on the inner label of each '
          'piece. As a general rule: cold wash, lay flat to dry, '
          'avoid tumble drying.',
    ),
    _FAQ(
      'Can I update my delivery address after ordering?',
      'You can update a delivery address before your order ships. '
          'Once dispatched, address changes may not be possible — '
          'contact support as soon as possible.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 48),
          children: [
            // ── App bar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 20, color: AppColors.ink),
                      ),
                    ),
                  ),
                  Text('Help & Support',
                      style: AppText.titleS.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 17)),
                ],
              ),
            ),

            // ── Contact card ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1816),
                  borderRadius:
                      BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                          Icons.mail_outline_rounded,
                          size: 20,
                          color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Support',
                            style: AppText.bodyS.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'support@drape.style',
                            style: AppText.caption.copyWith(
                                color: Colors.white
                                    .withValues(alpha: 0.55)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 13,
                        color:
                            Colors.white.withValues(alpha: 0.4)),
                  ],
                ),
              ),
            ),

            // ── FAQ section ────────────────────────────────────
            _SectionLabel('FREQUENTLY ASKED'),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: List.generate(_faqs.length, (i) {
                    return _FaqTile(
                      faq: _faqs[i],
                      isFirst: i == 0,
                      isLast: i == _faqs.length - 1,
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── App version ────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text('drape',
                      style: AppText.titleM.copyWith(
                          fontStyle: FontStyle.italic,
                          fontSize: 20)),
                  const SizedBox(height: 6),
                  Text('Version 0.1.0',
                      style: AppText.caption
                          .copyWith(color: AppColors.muted)),
                  const SizedBox(height: 2),
                  Text('© 2025 Drape Studio',
                      style: AppText.caption
                          .copyWith(color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── FAQ model + tile ──────────────────────────────────────────

class _FAQ {
  final String question, answer;
  const _FAQ(this.question, this.answer);
}

class _FaqTile extends StatefulWidget {
  final _FAQ faq;
  final bool isFirst, isLast;
  const _FaqTile(
      {required this.faq, required this.isFirst, required this.isLast});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: widget.isFirst
            ? const Radius.circular(AppRadius.lg)
            : Radius.zero,
        bottom: widget.isLast
            ? const Radius.circular(AppRadius.lg)
            : Radius.zero,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(widget.faq.question,
                        style: AppText.bodyS.copyWith(
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        size: 18, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(widget.faq.answer,
                  style: AppText.bodyS.copyWith(
                      color: AppColors.muted, height: 1.65)),
            ),
            crossFadeState: _open
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (!widget.isLast)
            Divider(height: 1, color: AppColors.line),
        ],
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        child: Text(text,
            style: AppText.eyebrow.copyWith(letterSpacing: 1.4)),
      );
}
