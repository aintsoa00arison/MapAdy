import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CustomLocationPin extends StatelessWidget {
  final Offset offset;
  final Animation<double> animation;
  final String? avatar;

  const CustomLocationPin({
    super.key,
    required this.offset,
    required this.animation,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    // Le badge est centré (32, 32) pour un widget 64x64
    return Positioned(
      left: offset.dx - 32,
      top: offset.dy - 32,
      child: IgnorePointer(
        child: ScaleTransition(
          scale: animation,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.secondary, AppColors.primary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.6),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: Image.asset(
                  "assets/avatar/${avatar ?? 'avatar_1.jpeg'}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
