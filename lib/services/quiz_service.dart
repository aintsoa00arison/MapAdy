import 'dart:convert';
import 'api_client.dart';
import 'endpoints.dart';

class QuizService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> getNextQuestion(int userId) async {
    try {
      final response = await _apiClient.get("${Endpoints.nextQuiz}/$userId");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> submitAnswer({
    required int userId,
    int? questionId,
    required bool isCorrect,
    String? generatedText,
  }) async {
    try {
      final response = await _apiClient.post(Endpoints.submitQuiz, {
        "user_id": userId,
        "question_id": questionId ?? -1,
        "is_correct": isCorrect,
        "generated_text": generatedText,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
