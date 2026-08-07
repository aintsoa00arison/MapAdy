import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'quiz/quiz_screen.dart';

class MapadyScreen extends StatelessWidget {
  const MapadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppColors.background,
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/city_map_bg.png', // Background stylisé fisheye
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  Icons.grid_4x4,
                  size: MediaQuery.of(context).size.width,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        
        // Bouton pour lancer le Quiz
        Positioned(
          bottom: 150,
          right: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuizScreen()),
              );
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.quiz,
                color: AppColors.secondary,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
