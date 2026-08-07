import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class QuestionHeader extends StatelessWidget {
  final String question;

  const QuestionHeader({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hexagonal background with glow
          ClipPath(
            clipper: HexagonClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 2),
              ),
            ),
          ),
          // Question text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              question.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Anybody',
                shadows: [
                  Shadow(
                    color: AppColors.secondary.withValues(alpha: 0.8),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;
    double edgeWidth = width * 0.25;

    path.moveTo(edgeWidth, 0);
    path.lineTo(width - edgeWidth, 0);
    path.lineTo(width, height / 2);
    path.lineTo(width - edgeWidth, height);
    path.lineTo(edgeWidth, height);
    path.lineTo(0, height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
