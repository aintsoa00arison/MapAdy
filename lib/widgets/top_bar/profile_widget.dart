import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../screens/profile/profile_screen.dart';

class ProfileWidget extends StatelessWidget {
  final String username;
  final String avatarPath;
  final VoidCallback? onReturn; // Callback pour rafraîchir après fermeture du profil

  const ProfileWidget({
    super.key,
    required this.username,
    required this.avatarPath,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final String fullAvatarPath = avatarPath.startsWith('assets') 
        ? avatarPath 
        : 'assets/avatar/$avatarPath';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        if (onReturn != null) onReturn!();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: AppTheme.profileImageDecoration,
            child: ClipOval(
              child: Image.asset(
                fullAvatarPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            username.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}
