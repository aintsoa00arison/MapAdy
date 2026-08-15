import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/bottom_bar/bottom_bar.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class GadgetListModal extends StatefulWidget {
  const GadgetListModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const GadgetListModal(),
    );
  }

  @override
  State<GadgetListModal> createState() => _GadgetListModalState();
}

class _GadgetListModalState extends State<GadgetListModal> {
  List<Map<String, dynamic>> _allGadgets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserGadgets();
  }

  Future<void> _fetchUserGadgets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      final user = jsonDecode(userJson);
      // On utilise le nouvel endpoint qui renvoie TOUS les gadgets avec leur quantité possédée
      final gadgets = await UserService().getUserGadgets(user['id']);
      if (mounted) {
        setState(() {
          _allGadgets = gadgets;
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
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              'INVENTAIRE TACTIQUE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 35),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (_allGadgets.isEmpty)
              _buildEmptyState(context)
            else
              _buildGadgetGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.inventory_2_outlined, color: Colors.white10, size: 48),
        const SizedBox(height: 16),
        const Text("AUCUN GADGET DANS LA BASE DE DONNÉES", style: TextStyle(color: Colors.white24, fontSize: 12)),
      ],
    );
  }

  Widget _buildGadgetGrid() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _allGadgets.length,
        itemBuilder: (context, index) {
          final gadget = _allGadgets[index];
          final int count = gadget['quantity'] ?? 0;
          final bool isOwned = count > 0;

          return Container(
            width: 110,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOwned ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOwned ? AppColors.primary.withValues(alpha: 0.4) : Colors.white10,
                width: isOwned ? 1.5 : 1,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: isOwned ? 1.0 : 0.3,
                      child: Image.asset(
                        'assets/skins/${gadget['image_url']}',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.radar, color: isOwned ? AppColors.primary : Colors.white24, size: 32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      gadget['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isOwned ? Colors.white : Colors.white24, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isOwned)
                      Text(
                        "DISPONIBLE",
                        style: TextStyle(color: AppColors.primary.withValues(alpha: 0.6), fontSize: 8, fontWeight: FontWeight.w900),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          navigationNotifier.value = 1; // Redirection Boutique
                        },
                        child: const Icon(Icons.add_circle_outline, color: Colors.white24, size: 18),
                      ),
                  ],
                ),
                if (isOwned)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Text('$count', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
