import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CONFIDENTIALITÉ', style: TextStyle(fontFamily: 'Anybody', fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('COLLECTE DES DONNÉES', 
              'Nous collectons vos données de géolocalisation pour le fonctionnement du jeu MapAdy. Ces données sont cryptées et ne sont jamais partagées.'),
            const SizedBox(height: 24),
            _buildSection('UTILISATION DU COMPTE GOOGLE', 
              'Votre email Google est utilisé uniquement pour l\'authentification unique et la sauvegarde de votre progression.'),
            const SizedBox(height: 24),
            _buildSection('SÉCURITÉ DU RÉSEAU', 
              'MapAdy utilise des protocoles de sécurité avancés pour protéger vos transactions de Crédits Cyber (CC) et vos actifs numériques.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
      ],
    );
  }
}
