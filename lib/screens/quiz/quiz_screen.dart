import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'widgets/question_header.dart';
import 'widgets/quiz_progress.dart';
import 'widgets/answer_option.dart';
import 'widgets/hint_section.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Timer and Close Button Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white38),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Anybody',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for balance
                ],
              ),
            ),

            const QuestionHeader(
              question: "Quel est le nom de cette rue ?",
            ),

            const QuizProgress(
              progress: 0.6,
              rating: "2/5",
            ),

            const SizedBox(height: 10),

            // Answer List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  AnswerOption(label: 'A', text: 'Rue de Rivoli', onTap: () {}),
                  AnswerOption(label: 'B', text: 'Avenue des Champs-Élysées', onTap: () {}),
                  AnswerOption(label: 'C', text: 'Boulevard Haussmann', onTap: () {}),
                  AnswerOption(label: 'D', text: 'Rue du Faubourg Saint-Honoré', onTap: () {}),
                ],
              ),
            ),

            const HintSection(),
          ],
        ),
      ),
    );
  }
}
