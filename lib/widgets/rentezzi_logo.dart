import 'package:flutter/material.dart';

class RentezziLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool useHero;

  const RentezziLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.useHero = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (showText) {
      imageWidget = Image.asset(
        'assets/images/logo.png',
        width: size * 1.8,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        ),
      );
    }

    if (useHero) {
      return Hero(
        tag: 'rentezzi_app_logo',
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.home_work_rounded,
          size: size * 0.52,
          color: Colors.white,
        ),
      ),
    );
  }
}
