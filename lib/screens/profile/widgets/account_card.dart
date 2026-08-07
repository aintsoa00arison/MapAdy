import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

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
          _buildActionRow(Icons.link, 'Lier le compte'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white10, height: 1),
          ),
          _buildActionRow(Icons.security, 'Politique de confidentialité'),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label) {
    return Padding(
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
    );
  }
}
