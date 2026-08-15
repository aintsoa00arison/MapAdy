import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class NormalOverlay extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onTap;

  const NormalOverlay({
    super.key,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: 40,
      right: 40,
      child: ScaleTransition(
        scale: animation,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 15)],
            ),
            child: const Text(
              "PARTIR À LA CONQUÊTE",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
