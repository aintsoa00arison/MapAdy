import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ConquestRadar extends StatelessWidget {
  final double? distance;
  final String baseName;
  final double accuracy;

  const ConquestRadar({super.key, this.distance, required this.baseName, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    String message = "SCAN RÉSEAU...";
    Color textColor = AppColors.primary;

    if (accuracy > 30) {
      message = "SIGNAL GPS FAIBLE... (${accuracy.toInt()}M)";
      textColor = Colors.orangeAccent;
    } else if (distance != null) {
      message = distance! > 1000 
          ? "CIBLE À ${(distance!/1000).toStringAsFixed(1)} KM" 
          : "CIBLE À ${distance!.toInt()} M";
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
