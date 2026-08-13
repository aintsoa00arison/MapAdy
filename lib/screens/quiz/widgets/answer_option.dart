import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onTap;
  final bool isCorrect; 
  final bool isWrong;
  final bool showFeedback;

  const AnswerOption({
    super.key,
    required this.label,
    required this.text,
    required this.onTap,
    this.isCorrect = false,
    this.isWrong = false,
    this.showFeedback = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white10;
    Color? glowColor;
    
    if (showFeedback) {
      if (isCorrect) {
        borderColor = Colors.greenAccent;
        glowColor = Colors.greenAccent.withValues(alpha: 0.3);
      } else if (isWrong) {
        borderColor = Colors.redAccent;
        glowColor = Colors.redAccent.withValues(alpha: 0.3);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: showFeedback ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: showFeedback && (isCorrect || isWrong) ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: glowColor != null ? [
                BoxShadow(color: glowColor, blurRadius: 10, spreadRadius: 1)
              ] : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white24),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (showFeedback && isCorrect)
                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                if (showFeedback && isWrong)
                  const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
