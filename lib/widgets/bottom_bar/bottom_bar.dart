import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'nav_item.dart';

class CyberBottomBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTap;

  const CyberBottomBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        height: 60, // Slightly more compact
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(15),
          // Rose Blur Border (Secondary color)
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NavItem(
              label: 'Mapady',
              iconPath: 'assets/icons/bottombar/map.png',
              fallbackIcon: Icons.map,
              isActive: activeIndex == 0,
              onTap: () => onTap(0),
            ),
            NavItem(
              label: 'Boutique',
              iconPath: 'assets/icons/bottombar/shop.png',
              fallbackIcon: Icons.shopping_cart,
              isActive: activeIndex == 1,
              onTap: () => onTap(1),
            ),
            NavItem(
              label: 'Classement',
              iconPath: 'assets/icons/bottombar/rank.png',
              fallbackIcon: Icons.leaderboard,
              isActive: activeIndex == 2,
              onTap: () => onTap(2),
            ),
            NavItem(
              label: 'Territoire',
              iconPath: 'assets/icons/bottombar/flag.png',
              fallbackIcon: Icons.flag,
              isActive: activeIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
