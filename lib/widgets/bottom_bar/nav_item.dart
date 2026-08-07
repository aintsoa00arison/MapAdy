import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NavItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final IconData fallbackIcon;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.label,
    required this.iconPath,
    required this.fallbackIcon,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.secondary : AppColors.textSecondary;

    return Expanded( // Added Expanded to NavItem to share space evenly
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: isActive
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.0),
                      AppColors.secondary.withValues(alpha: 0.2),
                    ],
                  ),
                  border: const Border(
                    bottom: BorderSide(color: AppColors.secondary, width: 3),
                  ),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 22,
                height: 22,
                color: color,
                errorBuilder: (context, error, stackTrace) => Icon(
                  fallbackIcon,
                  color: color,
                  size: 22,
                  shadows: isActive
                      ? [Shadow(color: AppColors.secondary, blurRadius: 10)]
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 9, // Reduced font size to avoid overflow
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'Anybody',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
