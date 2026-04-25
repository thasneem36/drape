import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Slide {
  final String eyebrow, title, emph, sub;
  final List<Color> tint;
  const _Slide(this.eyebrow, this.title, this.emph, this.sub, this.tint);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;

  final slides = const [
    _Slide('Welcome to Drape', 'Made slowly.', 'Worn for years.',
        'A considered wardrobe, shipped to your door.',
        [Color(0xFF3D3328), Color(0xFF1F1A14)]),
    _Slide('Curated', 'Edits from', 'our atelier.',
        'Silk, cashmere, linen — sourced with care.',
        [Color(0xFF8C5A3E), Color(0xFF5E3A26)]),
    _Slide('Yours', 'A wardrobe', 'that lasts.',
        'Save the pieces you love. We remember.',
        [Color(0xFF3A4A3F), Color(0xFF1E2A22)]),
  ];

  @override
  Widget build(BuildContext context) {
    final s = slides[step];
    return Scaffold(
      body: AnimatedContainer(
        duration: AppMotion.slow,
        curve: AppMotion.standard,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: s.tint),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(top: -90, right: -90, child: _Ring(size: 300, alpha: 0.4)),
              Positioned(top: -40, right: -40, child: _Ring(size: 200, alpha: 0.3)),
              Positioned(bottom: 100, left: -80, child: _Ring(size: 240, alpha: 0.2)),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 40, 26, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Drape.', style: AppText.titleL.copyWith(color: Colors.white, fontStyle: FontStyle.italic)),
                    const Spacer(),
                    Text(s.eyebrow.toUpperCase(), style: AppText.eyebrow.copyWith(color: Colors.white70)),
                    const SizedBox(height: 14),
                    RichText(
                      text: TextSpan(
                        style: AppText.displayXL.copyWith(color: Colors.white),
                        children: [
                          TextSpan(text: '${s.title}\n'),
                          TextSpan(text: s.emph, style: AppText.displayXL.copyWith(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(width: 290, child: Text(s.sub, style: AppText.bodyM.copyWith(color: Colors.white.withOpacity(0.78)))),
                    const SizedBox(height: 60),
                    Row(children: List.generate(slides.length, (i) {
                      return Expanded(child: GestureDetector(
                        onTap: () => setState(() => step = i),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 3,
                          decoration: BoxDecoration(
                            color: i <= step ? Colors.white.withOpacity(0.9) : Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ));
                    })),
                    const SizedBox(height: 20),
                    Row(children: [
                      if (step < slides.length - 1) ...[
                        Expanded(child: _onbBtn('SKIP', outlined: true,
                            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login))),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: _onbBtn('CONTINUE', onTap: () => setState(() => step += 1))),
                      ] else
                        Expanded(child: _onbBtn('BEGIN →',
                            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login))),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _onbBtn(String label, {VoidCallback? onTap, bool outlined = false}) {
  return Material(
    color: outlined ? Colors.transparent : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.base),
      side: outlined ? BorderSide(color: Colors.white.withOpacity(0.3)) : BorderSide.none,
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(AppRadius.base),
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Center(child: Text(label, style: AppText.label.copyWith(color: outlined ? Colors.white : AppColors.ink))),
      ),
    ),
  );
}

class _Ring extends StatelessWidget {
  final double size, alpha;
  const _Ring({required this.size, required this.alpha});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE8D7C4).withOpacity(alpha), width: 1.5),
        ),
      );
}
