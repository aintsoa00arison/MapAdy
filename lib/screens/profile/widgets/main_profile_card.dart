import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class MainProfileCard extends StatelessWidget {
  final String avatarPath;
  final String username;
  final String email;
  final VoidCallback onEditAvatar;

  const MainProfileCard({
    super.key,
    required this.avatarPath,
    required this.username,
    required this.email,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    // Résolution dynamique du chemin (nom seul ou chemin complet)
    final String fullAvatarPath = avatarPath.startsWith('assets') 
        ? avatarPath 
        : 'assets/avatar/$avatarPath';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.neonDecoration,
      child: Column(
        children: [
          GestureDetector(
            onTap: onEditAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black,
                    child: ClipOval(
                      child: Image.asset(
                        fullAvatarPath,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            username.toUpperCase(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  color: AppColors.primary,
                  shadows: [
                    Shadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 15)
                  ],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, color: Colors.green, size: 8),
                SizedBox(width: 8),
                Text(
                  'STATUT ACTIF',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
