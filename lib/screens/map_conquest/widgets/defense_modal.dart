import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/territory_service.dart';
import '../../../widgets/cyber_toast.dart';
import '../../../widgets/bottom_bar/bottom_bar.dart';

class DefenseModal extends StatefulWidget {
  final int userId;
  final int baseId;
  final String baseName;

  const DefenseModal({super.key, required this.userId, required this.baseId, required this.baseName});

  static Future<void> show(BuildContext context, int userId, int baseId, String baseName) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DefenseModal(userId: userId, baseId: baseId, baseName: baseName),
    );
  }

  @override
  State<DefenseModal> createState() => _DefenseModalState();
}

class _DefenseModalState extends State<DefenseModal> {
  List<Map<String, dynamic>> _allDefenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDefenses();
  }

  Future<void> _fetchDefenses() async {
    final gadgets = await UserService().getDefenseGadgets(widget.userId);
    if (mounted) {
      setState(() {
        _allDefenses = gadgets;
        _isLoading = false;
      });
    }
  }

  Future<void> _activateDefense(int gadgetId, String gadgetName) async {
    final result = await TerritoryService().activateDefense(widget.baseId, widget.userId, gadgetId);
    if (mounted) {
      if (result != null && result.containsKey('status')) {
        Navigator.pop(context);
        CyberToast.show(context, "PROTOCOLE $gadgetName ACTIVÉ SUR ${widget.baseName.toUpperCase()}");
      } else {
        CyberToast.show(context, result?['error'] ?? "ERREUR D'ACTIVATION", isError: true);
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
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'PROTOCOLE DE DÉFENSE : ${widget.baseName.toUpperCase()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 35),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.secondary))
            else if (_allDefenses.isEmpty)
               const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("AUCUN SYSTÈME DE DÉFENSE DISPONIBLE", style: TextStyle(color: Colors.white24, fontSize: 11)),
              )
            else
              _buildDefenseGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefenseGrid() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _allDefenses.length,
        itemBuilder: (context, index) {
          final def = _allDefenses[index];
          final int count = def['quantity'] ?? 0;
          final bool isOwned = count > 0;

          return Container(
            width: 110,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOwned ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOwned ? AppColors.secondary.withValues(alpha: 0.4) : Colors.white10,
                width: isOwned ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: isOwned ? 1.0 : 0.3,
                  child: Image.asset(
                    'assets/skins/${def['image_url']}',
                    width: 40,
                    height: 40,
                    errorBuilder: (c, e, s) => const Icon(Icons.shield, color: AppColors.secondary, size: 30),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  def['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isOwned ? Colors.white : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (isOwned)
                  GestureDetector(
                    onTap: () => _activateDefense(def['id'], def['name']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 10)],
                      ),
                      child: const Text("ACTIVER", style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      navigationNotifier.value = 1; // Redirige vers Boutique
                    },
                    child: const Icon(Icons.add_circle_outline, color: Colors.white24, size: 20),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
