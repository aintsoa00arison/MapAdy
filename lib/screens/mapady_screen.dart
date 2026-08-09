import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'quiz/quiz_screen.dart';

class MapadyScreen extends StatelessWidget {
  const MapadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Fond sombre uni au lieu de l'image de carte
          Container(
            color: AppColors.background,
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  Icons.grid_4x4,
                  size: 300,
                  color: AppColors.primary,
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
      ),
    );
  }
}
