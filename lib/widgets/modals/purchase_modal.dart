import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/shop_service.dart';
import '../../widgets/cyber_toast.dart';

class PurchaseModal extends StatelessWidget {
  final int itemId;
  final String itemName;
  final int price;
  final String category;

  const PurchaseModal({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.category,
  });

  static void show(BuildContext context, {required int itemId, required String itemName, required int price, required String category}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => PurchaseModal(itemId: itemId, itemName: itemName, price: price, category: category),
    );
  }

  Future<void> _processPurchase(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson == null) return;

    final user = jsonDecode(userJson);
    final result = await ShopService().purchaseItem(user['id'], itemId, category);

    if (context.mounted) {
      if (result != null) {
        await prefs.setString(AuthService.userKey, jsonEncode(result));
        UserSession.updateGold(result['gold'] ?? 0); // Mise à jour immédiate du HUD
        if (context.mounted) {
          Navigator.pop(context);
          CyberToast.show(context, "ACHAT RÉUSSI : $itemName");
        }
      } else {
        CyberToast.show(context, "CRÉDITS INSUFFISANTS OU ERREUR", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart_checkout, color: AppColors.secondary, size: 48),
                const SizedBox(height: 20),
                Text(
                  'CONFIRMER L\'ACHAT',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Anybody'),
                    children: [
                      const TextSpan(text: 'Voulez-vous acquérir '),
                      TextSpan(
                        text: itemName,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' pour '),
                      TextSpan(
                        text: '$price',
                        style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' CC ?'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white24),
                        ),
                        child: const Text('ANNULER', style: TextStyle(color: Colors.white54)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _processPurchase(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 10,
                          shadowColor: AppColors.secondary,
                        ),
                        child: const Text('ACHETER', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
