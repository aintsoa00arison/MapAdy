import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final String baseName;
  final bool isOwner;
  final VoidCallback onHack;

  const ActionButtons({super.key, required this.baseName, required this.isOwner, required this.onHack});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isOwner) 
          _buildBanner("BIENVENUE AGENT\n$baseName", AppColors.territoryOwned)
        else
          GestureDetector(
            onTap: onHack,
            child: _buildButton("HACKER $baseName", AppColors.primary),
          ),
      ],
    );
  }

  Widget _buildBanner(String text, Color color) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(text, textAlign: TextAlign.center, 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
    );
  }

  Widget _buildButton(String label, Color color) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 15)],
      ),
      child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2))),
    );
  }
}
