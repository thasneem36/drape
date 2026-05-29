// ─────────────────────────────────────────────────────────────
// AppContent — all copy + image content for onboarding slides
// and home-screen banners, in one easy-to-edit place.
//
// HOW TO EDIT
// ───────────
//  • Change any text field directly (eyebrow, title, etc.)
//  • Swap an image: paste a new URL into imageUrl.
//    Leave imageUrl as '' to show the gradient-only look.
//  • Add a slide/banner: copy an existing entry, give it a
//    new URL and colours — the UI picks it up automatically.
//  • Change gradient colours: edit the tint / bg lists.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── Onboarding slides ─────────────────────────────────────────
class OnboardingSlide {
  final String eyebrow, title, emph, sub, imageUrl;
  final List<Color> tint;
  const OnboardingSlide({
    required this.eyebrow,
    required this.title,
    required this.emph,
    required this.sub,
    required this.tint,
    this.imageUrl = '',
  });
}

const kOnboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    eyebrow: 'Welcome to Drape',
    title: 'Made slowly.',
    emph: 'Worn for years.',
    sub: 'A considered wardrobe, shipped to your door.',
    tint: [Color(0xFF3D3328), Color(0xFF1F1A14)],
    imageUrl:
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f'
        '?auto=format&fit=crop&w=600&q=80',
  ),
  OnboardingSlide(
    eyebrow: 'Curated',
    title: 'Edits from',
    emph: 'our atelier.',
    sub: 'Silk, cashmere, linen — sourced with care.',
    tint: [Color(0xFF8C5A3E), Color(0xFF5E3A26)],
    imageUrl:
        'https://images.unsplash.com/photo-1509631179647-0177331693ae'
        '?auto=format&fit=crop&w=600&q=80',
  ),
  OnboardingSlide(
    eyebrow: 'Yours',
    title: 'A wardrobe',
    emph: 'that lasts.',
    sub: 'Save the pieces you love. We remember.',
    tint: [Color(0xFF3A4A3F), Color(0xFF1E2A22)],
    imageUrl:
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa'
        '?auto=format&fit=crop&w=600&q=80',
  ),
];

// ── Home hero carousel banners ────────────────────────────────
class HeroBanner {
  final String eyebrow, title, sub, imageUrl;
  final List<Color> bg;
  final Color accent;
  const HeroBanner({
    required this.eyebrow,
    required this.title,
    required this.sub,
    required this.bg,
    required this.accent,
    this.imageUrl = '',
  });
}

const kHeroBanners = <HeroBanner>[
  HeroBanner(
    eyebrow: 'Spring Edit',
    title: 'Softness in Motion',
    sub: 'New drops from our Studio atelier',
    bg: [Color(0xFF3D3328), Color(0xFF1F1A14)],
    accent: Color(0xFFE8D7C4),
    imageUrl:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64'
        '?auto=format&fit=crop&w=300&q=80',
  ),
  HeroBanner(
    eyebrow: 'Limited',
    title: '40% off Silk',
    sub: 'A curated farewell to the season',
    bg: [Color(0xFF8C5A3E), Color(0xFF5E3A26)],
    accent: Color(0xFFF3E0CC),
    imageUrl:
        'https://images.unsplash.com/photo-1601924994987-69e26d50dc26'
        '?auto=format&fit=crop&w=300&q=80',
  ),
  HeroBanner(
    eyebrow: 'Members',
    title: 'Cashmere Club',
    sub: 'Early access for wishlist members',
    bg: [Color(0xFF3A4A3F), Color(0xFF1E2A22)],
    accent: Color(0xFFD5E2D0),
    imageUrl:
        'https://images.unsplash.com/photo-1559582798-678dfc71ccd8'
        '?auto=format&fit=crop&w=300&q=80',
  ),
];

// ── Home campaign banner ("The Quiet Edit") ───────────────────
// Single image shown on the right side of the dark strip.
// Set to '' to hide the image and keep the gradient-only look.
const kCampaignImageUrl =
    'https://images.unsplash.com/photo-1576566588028-4147f3842f27'
    '?auto=format&fit=crop&w=300&q=80';
