import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/quiz_service.dart';
import '../quiz/widgets/question_header.dart';
import '../quiz/widgets/answer_option.dart';
import '../quiz/widgets/quiz_progress.dart';
import '../../widgets/effects/glitch_effect.dart';
import 'widgets/opponent_progress_bar.dart';

class QuizBattleScreen extends StatefulWidget {
  final int baseId;
  final String baseName;
  final Map<String, dynamic> opponentData;

  const QuizBattleScreen({
    super.key,
    required this.baseId,
    required this.baseName,
    required this.opponentData,
  });

  @override
  State<QuizBattleScreen> createState() => _QuizBattleScreenState();
}

class _QuizBattleScreenState extends State<QuizBattleScreen> {
  final QuizService _quizService = QuizService();
  Map<String, dynamic>? _currentQuestion;
  int _userId = -1;
  int _questionsAnswered = 0;
  int _correctAnswersCount = 0;
  int _totalQuestions = 6;
  bool _isLoading = true;
  bool _showFeedback = false;
  int? _selectedIndex;
  
  // Opponent Logic (Simulated for now)
  int _opponentQuestionsAnswered = 0;
  Timer? _opponentTimer;
  final Random _random = Random();

  Timer? _gameTimer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _loadUserAndStart();
  }

  Future<void> _loadUserAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      final user = jsonDecode(userJson);
      _userId = user['id'];
      _loadNextQuestion();
      _startGameTimers();
    }
  }

  void _startGameTimers() {
    // Timer global du quiz
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _endBattle();
      }
    });

    // Simulation de l'adversaire (répond toutes les 5-8 secondes)
    _opponentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_opponentQuestionsAnswered < _totalQuestions && _random.nextDouble() < 0.15) {
        setState(() {
          _opponentQuestionsAnswered++;
        });
      }
    });
  }

  Future<void> _loadNextQuestion() async {
    setState(() => _isLoading = true);
    final question = await _quizService.getNextQuestion(_userId, baseId: widget.baseId);
    if (mounted) {
      setState(() {
        _currentQuestion = question;
        _isLoading = false;
        _showFeedback = false;
        _selectedIndex = null;
      });
    }
  }

  Future<void> _handleAnswer(int index) async {
    if (_showFeedback) return;

    final answers = _currentQuestion!['answers'] as List;
    final isCorrect = answers[index]['is_correct'] as bool;

    setState(() {
      _selectedIndex = index;
      _showFeedback = true;
      _questionsAnswered++;
      if (isCorrect) _correctAnswersCount++;
    });

    final isLast = _questionsAnswered >= _totalQuestions;

    await _quizService.submitAnswer(
      userId: _userId,
      questionId: _currentQuestion!['id'],
      isCorrect: isCorrect,
      baseId: widget.baseId,
      isLast: isLast,
      correctCount: _correctAnswersCount,
      totalQuestions: _totalQuestions,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (isLast) {
        _endBattle();
      } else {
        _loadNextQuestion();
      }
    });
  }

  void _endBattle() {
    _gameTimer?.cancel();
    _opponentTimer?.cancel();

    bool iWon = _correctAnswersCount > (_opponentQuestionsAnswered - 1); // Logic simple
    if (_correctAnswersCount == _opponentQuestionsAnswered) {
      // En cas d'égalité, le temps ou la précision pure trancherait
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: iWon ? Colors.greenAccent : Colors.redAccent, width: 2),
        ),
        title: Text(iWon ? "VICTOIRE RÉSEAU" : "ÉCHEC CRITIQUE", 
          style: TextStyle(color: iWon ? Colors.greenAccent : Colors.redAccent, fontFamily: 'Anybody', fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iWon ? Icons.emoji_events : Icons.gpp_bad, color: iWon ? Colors.greenAccent : Colors.redAccent, size: 64),
            const SizedBox(height: 20),
            Text("Votre score: $_correctAnswersCount / $_totalQuestions", style: const TextStyle(color: Colors.white)),
            Text("Adversaire: $_opponentQuestionsAnswered / $_totalQuestions", style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 20),
            Text(iWon ? "VOUS AVEZ PRIS LE CONTRÔLE !" : "L'ADVERSAIRE A GARDÉ LE SECTEUR.", 
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("RETOURNER AU HUB", style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _opponentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return GlitchEffect(
      active: false, // Pas de glitch pour l'instant en mode battle simple
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // BARRE DE L'ADVERSAIRE (HUD BATTLE)
              OpponentProgressBar(
                opponentName: widget.opponentData['username'],
                opponentAvatar: widget.opponentData['avatar'],
                currentQuestion: _opponentQuestionsAnswered,
                totalQuestions: _totalQuestions,
              ),
  
              QuizProgress(current: _questionsAnswered, total: _totalQuestions, secondsLeft: _secondsLeft),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "BATAILLE POUR ${widget.baseName.toUpperCase()}",
                  style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
  
              QuestionHeader(theme: _currentQuestion!['theme'], text: _currentQuestion!['text']),
              
              const SizedBox(height: 20),
              
              ...List.generate((_currentQuestion!['answers'] as List).length, (index) {
                final answers = _currentQuestion!['answers'] as List;
                return AnswerOption(
                  label: String.fromCharCode(65 + index),
                  text: answers[index]['text'],
                  isCorrect: answers[index]['is_correct'],
                  isWrong: _selectedIndex == index && !answers[index]['is_correct'],
                  showFeedback: _showFeedback,
                  onTap: () => _handleAnswer(index),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
