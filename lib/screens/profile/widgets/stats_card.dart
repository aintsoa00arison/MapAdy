import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import 'gadget_list_modal.dart';

class StatsCard extends StatelessWidget {
  final int gold;
  final int missions;
  final int gear;
  final String rank;

  const StatsCard({
    super.key,
    required this.gold,
    required this.missions,
    required this.gear,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.hudDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
              ),
              GestureDetector(
                onTap: () => GadgetListModal.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'VOIR GADGETS',
                    style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, 'HACKS', '$missions', AppColors.primary),
              _buildStatItem(context, 'TERRITOIRES', '$gear', AppColors.secondary),
              _buildStatItem(context, 'RANG', rank, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'Anybody',
            shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
          ),
        ),
      ],
    );
  }
}
