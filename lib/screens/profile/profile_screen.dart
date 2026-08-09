import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/cyber_toast.dart';
import '../auth/login_screen.dart';
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
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    
    if (userJson != null) {
      final localUser = jsonDecode(userJson);
      final serverUser = await UserService().getProfile(localUser['id']);
      if (serverUser != null) {
        setState(() {
          _userData = serverUser;
          _isLoading = false;
        });
        await prefs.setString(AuthService.userKey, jsonEncode(serverUser));
      } else {
        setState(() {
          _userData = localUser;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateAvatar(String newAvatarName) async {
    if (_userData == null) return;
    
    final updatedUser = await UserService().updateAvatar(_userData!['id'], newAvatarName);
    if (updatedUser != null) {
      setState(() {
        _userData = updatedUser;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AuthService.userKey, jsonEncode(updatedUser));
      if (mounted) CyberToast.show(context, "AVATAR MIS À JOUR");
    } else {
      if (mounted) CyberToast.show(context, "ERREUR MISE À JOUR AVATAR", isError: true);
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AvatarPicker(
        selectedAvatar: _userData?['avatar'] ?? 'avatar_1.jpeg',
        onAvatarSelected: (newAvatarName) {
          _updateAvatar(newAvatarName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

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
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        color: AppColors.primary,
        backgroundColor: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              MainProfileCard(
                avatarPath: _userData?['avatar'] ?? 'avatar_1.jpeg',
                username: _userData?['username'] ?? 'AGENT_UNKNOWN',
                email: _userData?['email'] ?? '---',
                onEditAvatar: _showAvatarPicker,
              ),
              const SizedBox(height: 20),
              StatsCard(
                gold: _userData?['gold'] ?? 0,
                missions: _userData?['quiz_victories'] ?? 0,
                gear: _userData?['territories_captured'] ?? 0,
                rank: _userData?['rank_title'] ?? 'ROOKIE',
              ),
              const SizedBox(height: 20),
              IntelCard(joinedDate: _userData?['joined_date'] ?? '---'),
              const SizedBox(height: 20),
              AccountCard(userId: _userData?['id']),
              const SizedBox(height: 30),
              _buildLogoutButton(context),
              const SizedBox(height: 40),
            ],
          ),
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
          onTap: () async {
            await AuthService().logout();
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
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
