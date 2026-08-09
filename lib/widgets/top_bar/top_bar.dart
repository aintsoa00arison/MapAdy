import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'profile_widget.dart';
import 'currency_widget.dart';
import 'settings_widget.dart';

class TopBar extends StatelessWidget {
  final String username;
  final int gold;
  final String avatarPath;
  final VoidCallback? onProfileReturn;

  const TopBar({
    super.key,
    required this.username,
    required this.gold,
    required this.avatarPath,
    this.onProfileReturn,
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
            ProfileWidget(
              username: username,
              avatarPath: avatarPath,
              onReturn: onProfileReturn,
            ),
            Row(
              children: [
                CurrencyWidget(amount: gold.toString()),
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
