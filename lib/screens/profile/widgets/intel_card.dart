import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class IntelCard extends StatelessWidget {
  final String joinedDate;

  const IntelCard({super.key, required this.joinedDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.hudDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INFOS SYSTEME',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.calendar_month, color: AppColors.secondary, size: 24),
            ),
            title: const Text(
              'Date d\'inscription',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            subtitle: Text(
              joinedDate,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
