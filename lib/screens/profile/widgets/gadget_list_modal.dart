import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/bottom_bar/bottom_bar.dart';
import '../../../services/auth_service.dart';
import '../../../services/shop_service.dart';

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
  List<dynamic> _userGadgets = [];
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
      final gadgets = await ShopService().getUserGadgets(user['id']);
      if (mounted) {
        setState(() {
          _userGadgets = gadgets ?? [];
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
              'MES GADGETS ACTIFS',
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
            else if (_userGadgets.isEmpty)
              _buildEmptyState(context)
            else
              _buildGadgetList(),
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
        const Text("AUCUN GADGET DANS L'INVENTAIRE", style: TextStyle(color: Colors.white24, fontSize: 12)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            navigationNotifier.value = 1;
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text("ALLER À LA BOUTIQUE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildGadgetList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _userGadgets.length,
        itemBuilder: (context, index) {
          final entry = _userGadgets[index];
          final gadget = entry['gadget']; // SQLAlchemy relationship
          final int count = entry['quantity'];

          return Container(
            width: 110,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/skins/${gadget['image_url']}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.radar, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      gadget['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "POSSÉDÉ",
                      style: TextStyle(color: AppColors.primary.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Text('x$count', style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
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
