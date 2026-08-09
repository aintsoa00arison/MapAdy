import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CurrencyWidget extends StatelessWidget {
  final String amount;

  const CurrencyWidget({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/coin.png',
            width: 16,
            height: 16,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.monetization_on,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Anybody',
            ),
          ),
        ],
      ),
    );
  }
}
