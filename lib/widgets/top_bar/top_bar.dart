import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'profile_widget.dart';
import 'currency_widget.dart';
import 'settings_widget.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), // Margins around the bar
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: AppTheme.neonDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ProfileWidget(
              username: 'Lenom',
              avatarPath: 'assets/images/avatar.png',
            ),
            Row(
              children: const [
                CurrencyWidget(amount: '1,250'),
                SizedBox(width: 10),
                SettingsWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
