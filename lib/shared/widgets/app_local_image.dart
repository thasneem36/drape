import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models.dart';
import '../../core/constants/app_spacing.dart';

/// Lightweight thumbnail used in Cart, Checkout, and Order History.
/// Shows [imageUrl] if available; otherwise a dark gradient with an
/// optional italic letter as a fallback label.
class ProductThumbnail extends StatelessWidget {
  final String imageUrl;
  final String? fallbackLabel;
  final BorderRadiusGeometry? borderRadius;

  const ProductThumbnail({
    super.key,
    required this.imageUrl,
    this.fallbackLabel,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.base);
    return ClipRRect(
      borderRadius: radius,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 250),
              errorWidget: (_, _, _) => _fallback(),
              placeholder: (_, _) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C251F), Color(0xFF1A1816)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: fallbackLabel != null
            ? Center(
                child: Text(
                  fallbackLabel!,
                  style: GoogleFonts.fraunces(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      );
}

class ProductArt extends StatelessWidget {
  final Product product;
  final double? fontSize;
  final BorderRadiusGeometry? borderRadius;
  final bool showLabel;
  const ProductArt({super.key, required this.product, this.fontSize, this.borderRadius, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final tint  = product.tint;
    final start = Color(tint.first);
    final end   = Color(tint.last);
    final fs    = fontSize ?? 18;
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.base);

    final hasImage = product.imageUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background (always rendered as placeholder/fallback)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [start, end], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withValues(alpha: 0.06), Colors.transparent, Colors.black.withValues(alpha: 0.14)],
                begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0, 0.55, 1],
              ),
            ),
          ),
          // Real product image when available
          if (hasImage)
            CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 300),
              errorWidget: (_, _, _) => const SizedBox.shrink(),
              placeholder: (_, _) => const SizedBox.shrink(),
            ),
          // Dark gradient overlay for text legibility over real images
          if (hasImage)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  stops: const [0.5, 1],
                ),
              ),
            ),
          if (showLabel && !hasImage)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  (product.art.isEmpty ? product.name : product.art).toLowerCase(),
                  style: GoogleFonts.fraunces(
                    fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: 0.85),
                    fontSize: fs, fontWeight: FontWeight.w400, height: 1.1, letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
