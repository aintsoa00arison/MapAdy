import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'widgets/avatar_picker.dart';
import 'widgets/main_profile_card.dart';
import 'widgets/stats_card.dart';
import 'widgets/intel_card.dart';
import 'widgets/account_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedAvatar = 'assets/avatar/avatar_1.jpeg';

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AvatarPicker(
        selectedAvatar: _selectedAvatar,
        onAvatarSelected: (newAvatar) {
          setState(() {
            _selectedAvatar = newAvatar;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PROFIL',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 20,
                shadows: [
                  Shadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10)
                ],
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sensors, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Carte Profil Principale
            MainProfileCard(
              avatarPath: _selectedAvatar,
              onEditAvatar: _showAvatarPicker,
            ),
            const SizedBox(height: 20),
            
            // Section Stats
            const StatsCard(),
            const SizedBox(height: 20),
            
            // Section Infos Système
            const IntelCard(),
            const SizedBox(height: 20),
            
            // Section Gestion Compte
            const AccountCard(),
            const SizedBox(height: 30),
            
            // Bouton Déconnexion
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Logique de déconnexion
          },
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: AppColors.secondary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'DECONNEXION',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
