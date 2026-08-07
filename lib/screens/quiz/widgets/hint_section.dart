import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class HintSection extends StatelessWidget {
  const HintSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.secondary, size: 28),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'INDICE DISPONIBLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '-500 CC',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Gadget indicators (the 3 circles)
          Row(
            children: List.generate(3, (index) {
              bool isAvailable = index == 0; // Mock: only one gadget available
              return Container(
                margin: const EdgeInsets.only(left: 8),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAvailable ? AppColors.secondary : Colors.white.withValues(alpha: 0.1),
                  boxShadow: isAvailable ? [
                    BoxShadow(color: AppColors.secondary.withValues(alpha: 0.5), blurRadius: 6)
                  ] : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
