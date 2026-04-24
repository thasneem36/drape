// ─────────────────────────────────────────────────────────────
// Re-usable page chrome: screen with scroll + optional bottom nav.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'bottom_nav.dart';
import 'buttons.dart';

class DrapeScaffold extends StatelessWidget {
  final Widget body;
  final TabItem? tab;
  final Color? bg;
  final Widget? fab;
  final Widget? bottom;
  const DrapeScaffold({
    super.key,
    required this.body,
    this.tab,
    this.bg,
    this.fab,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg ?? AppColors.bg,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: body,
      ),
      floatingActionButton: fab,
      bottomNavigationBar: bottom ??
          (tab != null ? DrapeBottomNav(current: tab!) : null),
    );
  }
}

/// Screen header: Brand mark + slot for right-side actions.
class ScreenHeader extends StatelessWidget {
  final String? title;
  final String? eyebrow;
  final List<Widget> actions;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  const ScreenHeader({
    super.key,
    this.title,
    this.eyebrow,
    this.actions = const [],
    this.leading,
    this.padding = const EdgeInsets.fromLTRB(18, 10, 18, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) leading!
          else if (Navigator.canPop(context))
            IconPill(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
          if (leading != null || Navigator.canPop(context)) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) Text(eyebrow!, style: AppText.eyebrow),
                if (title != null) Text(title!, style: AppText.titleM),
              ],
            ),
          ),
          ...actions.map((a) => Padding(padding: const EdgeInsets.only(left: 8), child: a)),
        ],
      ),
    );
  }
}

/// A big serif word + optional italic accent for section titles.
class SectionTitle extends StatelessWidget {
  final String text;
  final String? accent;
  final TextStyle? style;
  const SectionTitle({super.key, required this.text, this.accent, this.style});

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppText.titleXL;
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: text, style: base.copyWith(fontStyle: FontStyle.normal)),
        if (accent != null)
          TextSpan(text: ' $accent', style: base.copyWith(fontStyle: FontStyle.italic)),
      ]),
      style: base,
    );
  }
}

/// Section spacing helper.
class V extends StatelessWidget {
  final double h;
  const V(this.h, {super.key});
  @override Widget build(BuildContext context) => SizedBox(height: h);
}

class H extends StatelessWidget {
  final double w;
  const H(this.w, {super.key});
  @override Widget build(BuildContext context) => SizedBox(width: w);
}
