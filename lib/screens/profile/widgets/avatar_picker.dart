import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/bottom_bar/bottom_bar.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class AvatarPicker extends StatefulWidget {
  final String selectedAvatar;
  final Function(String) onAvatarSelected;

  const AvatarPicker({
    super.key,
    required this.selectedAvatar,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  List<String> _ownedAvatars = ['avatar_default.jpeg'];
  bool _isLoading = true;

  // Liste complète des avatars disponibles
  static const List<Map<String, dynamic>> _allAvatars = [
    {'name': 'Standard', 'path': 'avatar_default.jpeg'},
    {'name': 'Scavenger', 'path': 'avatar_1.jpeg'},
    {'name': 'Vision', 'path': 'avatar_2.jpeg'},
    {'name': 'Slice', 'path': 'avatar_3.jpeg'},
    {'name': 'Stalker', 'path': 'avatar_4.jpeg'},
    {'name': 'Hacker', 'path': 'avatar_5.jpeg'},
    {'name': 'Netrunner', 'path': 'avatar_6.jpeg'},
    {'name': 'Skull', 'path': 'avatar_7.jpeg'},
    {'name': 'Puppet', 'path': 'avatar_8.jpeg'},
    {'name': 'Sicko', 'path': 'avatar_9.jpeg'},
    {'name': 'Shadow', 'path': 'avatar_10.jpeg'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchOwnedAvatars();
  }

  Future<void> _fetchOwnedAvatars() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      final user = jsonDecode(userJson);
      final owned = await UserService().getOwnedAvatars(user['id']);
      if (mounted) {
        setState(() {
          if (owned != null) _ownedAvatars = ['avatar_default.jpeg', ...owned];
          _isLoading = false;
        });
      }
    }
  }

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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'CHOISIR UN AVATAR OPÉRATIONNEL',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
            else
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _allAvatars.length,
                  itemBuilder: (context, index) {
                    final avatarData = _allAvatars[index];
                    final String avatarName = avatarData['name'];
                    final String avatarFile = avatarData['path'];
                    final String fullPath = 'assets/avatar/$avatarFile';
                    
                    final bool isOwned = _ownedAvatars.contains(avatarFile);
                    final isSelected = widget.selectedAvatar == avatarFile || widget.selectedAvatar == fullPath;

                    return GestureDetector(
                      onTap: () {
                        if (!isOwned) {
                          Navigator.pop(context); 
                          Navigator.pop(context); 
                          navigationNotifier.value = 1; 
                        } else {
                          widget.onAvatarSelected(avatarFile);
                          Navigator.pop(context);
                        }
                      },
                      child: Column(
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected 
                                      ? AppColors.primary 
                                      : (isOwned ? Colors.white24 : Colors.white10),
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
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(
                                    opacity: isOwned ? 1.0 : 0.3,
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.black,
                                      child: ClipOval(
                                        child: Image.asset(
                                          fullPath,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.person_off,
                                            color: AppColors.primary,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isOwned)
                                    const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.secondary,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            avatarName.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : Colors.white30,
                              fontSize: 7, // Even smaller font size
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
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
