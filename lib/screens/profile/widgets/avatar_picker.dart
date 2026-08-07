import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AvatarPicker extends StatelessWidget {
  final String selectedAvatar;
  final Function(String) onAvatarSelected;

  const AvatarPicker({
    super.key,
    required this.selectedAvatar,
    required this.onAvatarSelected,
  });

  // Liste mise à jour avec les 10 avatars
  static const List<String> _availableAvatars = [
    'assets/avatar/avatar_1.jpeg',
    'assets/avatar/avatar_2.jpeg',
    'assets/avatar/avatar_3.jpeg',
    'assets/avatar/avatar_4.jpeg',
    'assets/avatar/avatar_5.jpeg',
    'assets/avatar/avatar_6.jpeg',
    'assets/avatar/avatar_7.jpeg',
    'assets/avatar/avatar_8.jpeg',
    'assets/avatar/avatar_9.jpeg',
    'assets/avatar/avatar_10.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de saisie HUD en haut
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 25),
            
            Text(
              'CHOISIR UN AVATAR OPERATIONNEL',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 35),
            
            // Grille/Liste d'avatars
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _availableAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = _availableAvatars[index];
                  final isSelected = selectedAvatar == avatar;
                  
                  return GestureDetector(
                    onTap: () {
                      onAvatarSelected(avatar);
                      Navigator.pop(context);
                    },
                    child: AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.white24,
                            width: 2,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              blurRadius: 15,
                              spreadRadius: 2,
                            )
                          ] : [],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.black,
                          child: ClipOval(
                            child: Image.asset(
                              avatar,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person_off,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'DÉFILEZ POUR VOIR PLUS',
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
