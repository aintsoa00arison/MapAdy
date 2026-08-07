import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class UserRankBanner extends StatelessWidget {
  final int rank;
  final String name;

  const UserRankBanner({
    super.key,
    required this.rank,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow effect trapezoidal shape
          ClipPath(
            clipper: BannerClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.3),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1),
              ),
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'VOTRE RANG',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '#$rank',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Anybody',
                  shadows: [
                    Shadow(color: AppColors.secondary.withValues(alpha: 0.8), blurRadius: 20),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.primary, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double offset = 35.0;
    path.moveTo(offset, 0);
    path.lineTo(size.width - offset, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - offset, size.height);
    path.lineTo(offset, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
