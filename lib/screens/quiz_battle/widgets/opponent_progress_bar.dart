import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class OpponentProgressBar extends StatelessWidget {
  final String opponentName;
  final String opponentAvatar;
  final int currentQuestion;
  final int totalQuestions;
  final bool isWinner;

  const OpponentProgressBar({
    super.key,
    required this.opponentName,
    required this.opponentAvatar,
    required this.currentQuestion,
    required this.totalQuestions,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (currentQuestion / totalQuestions).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(bottom: BorderSide(color: isWinner ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white10)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isWinner ? Colors.redAccent : AppColors.secondary,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("assets/avatar/$opponentAvatar"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      opponentName.toUpperCase(),
                      style: TextStyle(
                        color: isWinner ? Colors.redAccent : Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      "HACK : $currentQuestion/$totalQuestions",
                      style: const TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          height: 4,
                          width: constraints.maxWidth * progress,
                          decoration: BoxDecoration(
                            color: isWinner ? Colors.redAccent : AppColors.secondary.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: (isWinner ? Colors.redAccent : AppColors.secondary).withValues(alpha: 0.3),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
