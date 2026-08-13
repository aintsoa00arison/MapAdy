import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../privacy_screen.dart';
import '../link_account_screen.dart';

class AccountCard extends StatelessWidget {
  final int? userId;

  const AccountCard({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.hudDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GESTION DU COMPTE',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          _buildActionRow(
            context,
            Icons.link,
            'Lier le compte',
            onTap: () {
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LinkAccountScreen(userId: userId!)),
                );
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white10, height: 1),
          ),
          _buildActionRow(
            context,
            Icons.security,
            'Politique de confidentialité',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
          ],
        ),
      ),
    );
  }
}
