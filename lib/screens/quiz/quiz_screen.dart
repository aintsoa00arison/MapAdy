import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/quiz_service.dart';
import '../../widgets/cyber_toast.dart';
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
  final QuizService _quizService = QuizService();
  
  int _secondsRemaining = 60;
  Timer? _timer;
  
  Map<String, dynamic>? _currentQuestion;
  int _correctAnswersCount = 0;
  int _questionsAnswered = 0;
  late int _totalQuestions;
  bool _isLoading = true;
  int? _userId;
  
  // State for answer feedback
  int? _selectedIndex;
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    _totalQuestions = 5 + (DateTime.now().millisecond % 3);
    _loadUserAndStart();
  }

  Future<void> _loadUserAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      final user = jsonDecode(userJson);
      _userId = user['id'];
      _loadNextQuestion();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            _endQuiz(timeout: true);
          }
        });
      }
    });
  }

  Future<void> _loadNextQuestion() async {
    if (_userId == null) return;
    
    setState(() {
      _isLoading = true;
      _showFeedback = false;
      _selectedIndex = null;
    });
    
    final question = await _quizService.getNextQuestion(_userId!);
    
    if (mounted) {
      if (question != null) {
        setState(() {
          _currentQuestion = question;
          _isLoading = false;
        });
      } else {
        CyberToast.show(context, "ERREUR CHARGEMENT QUESTION", isError: true);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleAnswer(int index, bool isCorrect) async {
    if (_userId == null || _currentQuestion == null || _showFeedback) return;

    setState(() {
      _selectedIndex = index;
      _showFeedback = true;
    });

    if (isCorrect) _correctAnswersCount++;
    _questionsAnswered++;

    // Small delay to let user see feedback before loading next
    await Future.delayed(const Duration(milliseconds: 800));

    await _quizService.submitAnswer(
      userId: _userId!,
      questionId: _currentQuestion!['id'],
      isCorrect: isCorrect,
      generatedText: _currentQuestion!['is_dynamic'] ? _currentQuestion!['text'] : null,
    );

    if (_questionsAnswered >= _totalQuestions) {
      _endQuiz();
    } else {
      _loadNextQuestion();
    }
  }

  void _endQuiz({bool timeout = false}) {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        title: Text(timeout ? "TEMPS ÉCOULÉ" : "MISSION TERMINÉE", 
          style: const TextStyle(color: AppColors.primary, fontFamily: 'Anybody', fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.analytics_outlined, color: AppColors.secondary, size: 48),
            const SizedBox(height: 20),
            Text("Score de précision: $_correctAnswersCount / $_questionsAnswered", 
              style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Text("+${_correctAnswersCount * 10} Crédits Cyber acquis.", 
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("RETOUR AU RÉSEAU", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final answers = _currentQuestion!['answers'] as List<dynamic>;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Timer Header
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
                  const SizedBox(width: 48),
                ],
              ),
            ),

            QuestionHeader(
              question: _currentQuestion!['text'],
            ),

            QuizProgress(
              progress: _questionsAnswered / _totalQuestions,
              rating: "$_correctAnswersCount / $_totalQuestions",
            ),

            const SizedBox(height: 10),

            // Use Expanded + Column (if few items) or ListView with Fixed Size to avoid scroll if possible
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // Prevent scrolling if everything fits
                child: Column(
                  children: List.generate(answers.length, (index) {
                    final answer = answers[index];
                    final List<String> labels = ['A', 'B', 'C', 'D'];
                    return AnswerOption(
                      label: labels[index], 
                      text: answer['text'], 
                      showFeedback: _showFeedback,
                      isCorrect: answer['is_correct'],
                      isWrong: _selectedIndex == index && !answer['is_correct'],
                      onTap: () => _handleAnswer(index, answer['is_correct']),
                    );
                  }),
                ),
              ),
            ),

            HintSection(hints: List<String>.from(_currentQuestion!['hints'])),
          ],
        ),
      ),
    );
  }
}
