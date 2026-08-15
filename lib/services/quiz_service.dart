import 'dart:convert';
import 'api_client.dart';
import 'endpoints.dart';

class QuizService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> getNextQuestion(int userId, {int? baseId}) async {
    try {
      String url = "${Endpoints.nextQuiz}/$userId";
      if (baseId != null) url += "?base_id=$baseId";
      
      final response = await _apiClient.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> submitAnswer({
    required int userId,
    required int questionId,
    required bool isCorrect,
    int? baseId,
    bool isLast = false,
    int correctCount = 0,
    int totalQuestions = 6,
    String? debugGadget, // Nouveau
  }) async {
    try {
      final response = await _apiClient.post(Endpoints.submitQuiz, {
        "user_id": userId,
        "question_id": questionId,
        "is_correct": isCorrect,
        "base_id": baseId,
        "is_last": isLast,
        "correct_count": correctCount,
        "total_questions": totalQuestions,
        "debug_gadget": debugGadget,
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> quitQuiz(int userId) async {
    try {
      final response = await _apiClient.post("/quiz/quit", {"user_id": userId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
