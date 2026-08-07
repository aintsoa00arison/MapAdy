import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

import '../../widgets/modals/settings_modal.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => SettingsModal.show(context),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: AppTheme.profileImageDecoration, // Using the same glow effect
        child: Image.asset(
          'assets/icons/settings.svg',
          width: 24,
          height: 24,
          color: AppColors.primary,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.settings,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
