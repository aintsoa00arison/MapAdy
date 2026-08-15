import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ConquestHUD extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onClose;

  const ConquestHUD({
    super.key,
    required this.userData,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bouton de sortie (Haut Gauche)
        Positioned(
          top: 100, // Ajusté pour être sous la TopBar
          left: 20,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background.withValues(alpha: 0.8),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Icon(Icons.close, color: AppColors.primary, size: 20),
            ),
          ),
        ),

        // PIECES + AVATAR (BAS)
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bulles des Cyber-Crédits
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "${userData?['gold'] ?? 0} CC",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Bulle de l'Avatar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.4), blurRadius: 15)],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/avatar/${userData?['avatar'] ?? 'avatar_1.jpeg'}"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
