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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vertical divider line before currency
          Container(
            height: 24,
            width: 1.5,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/icons/coin.png',
            width: 18,
            height: 18,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.monetization_on,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}
