import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import 'profile_widget.dart';
import 'currency_widget.dart';
import 'settings_widget.dart';

class TopBar extends StatelessWidget {
  final String username;
  final int gold; // Keep for compatibility but not passed to child
  final String avatarPath;
  final VoidCallback? onProfileReturn;
  final bool showBackButton;
  final VoidCallback? onBack;

  const TopBar({
    super.key,
    required this.username,
    required this.gold,
    required this.avatarPath,
    this.onProfileReturn,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: AppTheme.neonDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showBackButton)
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                ),
              )
            else
              ProfileWidget(
                username: username,
                avatarPath: avatarPath,
                onReturn: onProfileReturn,
              ),
            Row(
              children: [
                const CurrencyWidget(),
                const SizedBox(width: 10),
                const SettingsWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
