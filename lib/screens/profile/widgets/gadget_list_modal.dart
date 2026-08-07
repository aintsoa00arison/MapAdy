import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/bottom_bar/bottom_bar.dart';

class GadgetListModal extends StatelessWidget {
  const GadgetListModal({super.key});

  static const List<Map<String, dynamic>> _myGadgets = [
    {'name': 'Scanner EM', 'icon': Icons.radar, 'level': 'LVL 2', 'count': 1},
    {'name': 'Clé Master', 'icon': Icons.vpn_key_outlined, 'level': 'LVL 0', 'count': 0},
    {'name': 'Brouilleur', 'icon': Icons.portable_wifi_off, 'level': 'LVL 4', 'count': 3},
    {'name': 'Drone Spy', 'icon': Icons.settings_remote, 'level': 'LVL 0', 'count': 0},
    {'name': 'Vision IR', 'icon': Icons.visibility, 'level': 'LVL 3', 'count': 1},
  ];

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const GadgetListModal(),
    );
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
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _myGadgets.length,
                itemBuilder: (context, index) {
                  final gadget = _myGadgets[index];
                  final bool hasNone = gadget['count'] == 0;

                  return Container(
                    width: 110,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hasNone 
                            ? Colors.white10 
                            : AppColors.primary.withValues(alpha: 0.3)
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              gadget['icon'], 
                              color: hasNone ? Colors.white24 : AppColors.primary, 
                              size: 32
                            ),
                            const SizedBox(height: 12),
                            Text(
                              gadget['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: hasNone ? Colors.white38 : Colors.white, 
                                fontSize: 11, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasNone ? 'NON POSSÉDÉ' : gadget['level'],
                              style: TextStyle(
                                color: hasNone ? Colors.white10 : AppColors.primary.withValues(alpha: 0.6), 
                                fontSize: 9, 
                                fontWeight: FontWeight.w900
                              ),
                            ),
                          ],
                        ),
                        
                        // Count indicator top right
                        if (!hasNone)
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'x${gadget['count']}',
                                style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                        // Plus button bottom left if 0
                        if (hasNone)
                          Positioned(
                            bottom: -5,
                            left: -5,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Close modal
                                Navigator.pop(context); // Exit profile screen
                                navigationNotifier.value = 1; // Go to Shop tab
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Colors.black, size: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
