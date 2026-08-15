import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class QuizProgress extends StatelessWidget {
  final int current;
  final int total;
  final int secondsLeft;

  const QuizProgress({
    super.key,
    required this.current,
    required this.total,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    double progress = current / total;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "QUESTION $current/$total",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: secondsLeft < 10 ? Colors.red.withValues(alpha: 0.2) : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: secondsLeft < 10 ? Colors.red : Colors.white24,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined, 
                      size: 14, 
                      color: secondsLeft < 10 ? Colors.red : Colors.white70
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${secondsLeft}S",
                      style: TextStyle(
                        color: secondsLeft < 10 ? Colors.red : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 6,
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
