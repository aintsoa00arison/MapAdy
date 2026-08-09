import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class QuestionHeader extends StatelessWidget {
  final String question;

  const QuestionHeader({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Center(
        child: Text(
          question.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16, // Reduced font size
            fontWeight: FontWeight.w800,
            fontFamily: 'Anybody',
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
