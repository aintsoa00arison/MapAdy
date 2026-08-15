import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../logic/debug_conquest_controller.dart';

class DebugDefenseSelector extends StatelessWidget {
  final Function(DebugDefenseType) onSelected;

  const DebugDefenseSelector({super.key, required this.onSelected});

  static void show(BuildContext context, Function(DebugDefenseType) onSelected) {
    showDialog(
      context: context,
      builder: (context) => DebugDefenseSelector(onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.primary, width: 2),
      ),
      title: const Text(
        "SIMULATEUR DE DÉFENSE",
        style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(context, "AUCUNE DÉFENSE", DebugDefenseType.none, Icons.block),
          _buildOption(context, "GLITCH SCREEN", DebugDefenseType.glitchScreen, Icons.vignette),
          _buildOption(context, "IRON TWIN (10 Q)", DebugDefenseType.ironTwin, Icons.reorder),
          _buildOption(context, "FROST TRAP", DebugDefenseType.frostTrap, Icons.ac_unit),
          _buildOption(context, "DRAIN CASH", DebugDefenseType.drainCash, Icons.monetization_on),
          _buildOption(context, "SAFE DROP (2 CHANCES)", DebugDefenseType.safeDrop, Icons.security),
          _buildOption(context, "GHOST KEY (BYPASS ALL)", DebugDefenseType.ghostKey, Icons.vpn_key),
          _buildOption(context, "CYBER SPY (REVEAL 2)", DebugDefenseType.cyberspy, Icons.remove_red_eye),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, DebugDefenseType type, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.pop(context); // ON FERME D'ABORD
        onSelected(type);      // ON LANCE LE QUIZ APRÈS
      },
    );
  }
}
