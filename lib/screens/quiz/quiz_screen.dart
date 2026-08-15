import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/quiz_service.dart';
import 'widgets/question_header.dart';
import 'widgets/answer_option.dart';
import 'widgets/hint_section.dart';
import 'widgets/quiz_progress.dart';
import '../../widgets/cyber_toast.dart';

import '../map_conquest/widgets/map_display.dart';
import '../../widgets/effects/glitch_effect.dart';

class QuizScreen extends StatefulWidget {
  final int? baseId; 
  final String? baseName;
  final List<String>? debugEffects;
  const QuizScreen({super.key, this.baseId, this.baseName, this.debugEffects});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  Map<String, dynamic>? _currentQuestion;
  int _userId = -1;
  int _questionsAnswered = 0;
  int _correctAnswersCount = 0;
  int _totalQuestions = 6;
  bool _isLoading = true;
  bool _showFeedback = false;
  int? _selectedIndex;
  bool _isGlitching = false;
  bool _ghostKeyActive = false;
  
  int _safeDropCharges = 0;
  List<int> _eliminatedIndices = [];

  int _cyberSpyCharges = 0;
  bool _isSpyRevealing = false;

  Timer? _timer;
  Timer? _glitchTimer;
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
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _endQuiz(timeout: true);
      }
    });
  }

  Future<void> _loadNextQuestion() async {
    setState(() => _isLoading = true);
    final question = await _quizService.getNextQuestion(_userId, baseId: widget.baseId);
    
    if (mounted && question != null) {
      List<dynamic> effects = widget.debugEffects ?? question['active_effects'] ?? [];
      
      if (effects.contains('GHOSTKEY')) {
        _ghostKeyActive = true;
        effects = ['GHOSTKEY'];
      }

      setState(() {
        _currentQuestion = question;
        _totalQuestions = _ghostKeyActive ? 6 : ((widget.debugEffects?.contains('IRON_TWIN') ?? false) ? 10 : (question['total_needed'] ?? 6));
        _isLoading = false;
        _showFeedback = false;
        _selectedIndex = null;
        _eliminatedIndices = [];
        _isSpyRevealing = false;
        _isGlitching = !_ghostKeyActive && effects.contains('GLITCHSCREEN');
        
        if (!_ghostKeyActive) {
          if (effects.contains('SAFEDROP') && _questionsAnswered == 0) {
            _safeDropCharges = 2;
          }
          if (effects.contains('CYBERSPY') && _questionsAnswered == 0) {
            _cyberSpyCharges = 2;
          }
        }
      });

      if (_isGlitching) {
        _glitchTimer?.cancel();
        _glitchTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _isGlitching = false);
        });
      }
    }
  }

  Future<void> _handleAnswer(int index) async {
    if (_showFeedback || _eliminatedIndices.contains(index)) return;

    final answers = _currentQuestion!['answers'] as List;
    final isCorrect = answers[index]['is_correct'] as bool;

    if (!isCorrect && _safeDropCharges > 0 && !_ghostKeyActive) {
      setState(() {
        _safeDropCharges--;
        _eliminatedIndices.add(index);
      });
      CyberToast.show(context, "BOUCLIER SAFEDROP ACTIVÉ ! -1 CHARGE");
      return;
    }

    setState(() {
      _selectedIndex = index;
      _showFeedback = true;
      _questionsAnswered++;
      if (isCorrect) _correctAnswersCount++;
    });

    final isLast = _questionsAnswered >= _totalQuestions;

    final response = await _quizService.submitAnswer(
      userId: _userId,
      questionId: _currentQuestion!['id'],
      isCorrect: isCorrect,
      baseId: _ghostKeyActive ? null : widget.baseId,
      isLast: isLast,
      correctCount: _correctAnswersCount,
      totalQuestions: _totalQuestions,
      debugGadget: widget.debugEffects?.first, // Envoi du gadget simulé au back
    );

    if (response != null && response.containsKey('gold')) {
      UserSession.updateGold(response['gold']);
    }

    // FROST TRAP DETECTION : Arrêt immédiat si activé sur la base et erreur commise
    if (!_ghostKeyActive && response != null && response['stop_quiz'] == true) {
      _timer?.cancel();
      _showFrostTrapDialog(response['status'] ?? "PIÈGE ACTIVÉ");
      return;
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (isLast) {
        _endQuiz();
      } else {
        _loadNextQuestion();
      }
    });
  }

  void _useCyberSpy() {
    if (_cyberSpyCharges > 0 && !_showFeedback && !_isSpyRevealing) {
      setState(() {
        _cyberSpyCharges--;
        _isSpyRevealing = true;
      });
      CyberToast.show(context, "CYBERSPY : RÉPONSE ANALYSÉE");
    }
  }

  void _showFrostTrapDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.redAccent, width: 2)),
        title: const Text("SYSTÈME GELÉ", style: TextStyle(color: Colors.redAccent, fontFamily: 'Anybody', fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.ac_unit, color: Colors.cyanAccent, size: 48),
          const SizedBox(height: 20),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ]),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, 
          child: const Text("REPLI TACTIQUE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text("ALERTE ABANDON", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text("Quitter maintenant entraînera une pénalité de 50 CC et un recul dans le rang. Confirmer ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CONTINUER")),
          TextButton(
            onPressed: () async {
              final result = await _quizService.quitQuiz(_userId);
              if (result != null && result.containsKey('gold')) {
                UserSession.updateGold(result['gold']);
              }
              if (context.mounted) Navigator.pop(context, true);
            },
            child: const Text("QUITTER (-50 CC)", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return shouldQuit ?? false;
  }

  void _endQuiz({bool timeout = false}) {
    _timer?.cancel();
    bool isConquestSuccess = (widget.baseId != null || _ghostKeyActive) && _correctAnswersCount == _totalQuestions;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primary, width: 2)),
        title: Text(timeout ? "TEMPS ÉCOULÉ" : "MISSION TERMINÉE", style: const TextStyle(color: AppColors.primary, fontFamily: 'Anybody', fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_ghostKeyActive)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("GHOSTKEY ACTIVE : BYPASS TOTAL", style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            Icon(isConquestSuccess ? Icons.verified_user : Icons.analytics_outlined, color: isConquestSuccess ? Colors.greenAccent : AppColors.secondary, size: 48),
            const SizedBox(height: 20),
            Text("Précision: $_correctAnswersCount / $_totalQuestions", style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 12),
            if (isConquestSuccess)
              const Text("HACK RÉUSSI ! SECTEUR CAPTURÉ.", textAlign: TextAlign.center, style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
            else
              const Text("HACK ÉCHOUÉ. SANS-FAUTE REQUIS.", textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            const SizedBox(height: 8),
            Text("+${_correctAnswersCount * 10}${_correctAnswersCount == _totalQuestions ? ' + 20 bonus' : ''} CC acquis.", style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, 
          child: const Text("TERMINER", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == -1 || _isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    final answers = _currentQuestion!['answers'] as List;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: GlitchEffect(
        active: _isGlitching,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                QuizProgress(current: _questionsAnswered, total: _totalQuestions, secondsLeft: _secondsLeft),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_ghostKeyActive)
                        const Icon(Icons.vpn_key, color: Colors.cyanAccent, size: 24),
                      if (_safeDropCharges > 0 && !_ghostKeyActive)
                        ...List.generate(_safeDropCharges, (index) => 
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.security, color: Colors.greenAccent, size: 18),
                          )
                        ),
                      if (_cyberSpyCharges > 0 && !_ghostKeyActive)
                        GestureDetector(
                          onTap: _useCyberSpy,
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 1),
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.remove_red_eye, color: AppColors.primary, size: 20),
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Text("$_cyberSpyCharges", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
  
                if (widget.baseName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _ghostKeyActive ? "INFILTRATION SPECTRE ACTIVE" : "CIBLE : ${widget.baseName!.toUpperCase()}", 
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Anybody')
                    ),
                  ),
                QuestionHeader(theme: _currentQuestion!['theme'], text: _currentQuestion!['text']),
                const SizedBox(height: 20),
                ...List.generate(answers.length, (index) {
                  final isCorrect = answers[index]['is_correct'] as bool;
                  final isEliminated = _eliminatedIndices.contains(index);
                  bool isSpyRevealed = _isSpyRevealing && isCorrect;
  
                  return AnswerOption(
                    label: String.fromCharCode(65 + index),
                    text: answers[index]['text'],
                    isCorrect: isCorrect,
                    isWrong: isEliminated || (_selectedIndex == index && !isCorrect),
                    showFeedback: isEliminated || (_showFeedback && (_selectedIndex == index || isCorrect)) || isSpyRevealed,
                    onTap: () => _handleAnswer(index),
                  );
                }),
                const Spacer(),
                HintSection(hints: List<String>.from(_currentQuestion!['hints'] ?? [])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
