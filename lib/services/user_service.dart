import 'dart:convert';
import 'api_client.dart';
import 'endpoints.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> getProfile(int userId) async {
    try {
      final response = await _apiClient.get("${Endpoints.profile}/$userId");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>?> getLeaderboard() async {
    try {
      final response = await _apiClient.get(Endpoints.leaderboard);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>?> getOwnedAvatars(int userId) async {
    try {
      final response = await _apiClient.get("${Endpoints.profile}/$userId${Endpoints.ownedAvatars}");
      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateAvatar(int userId, String avatarName) async {
    try {
      final response = await _apiClient.post("${Endpoints.profile}/$userId${Endpoints.updateAvatar}", {"avatar": avatarName});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> sendVerificationCode(int userId, String email) async {
    try {
      final response = await _apiClient.post(
        "${Endpoints.profile}/$userId${Endpoints.sendCode}", 
        {"email": email}
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyCodeAndUpdateEmail(int userId, String email, String code) async {
    try {
      final response = await _apiClient.post(
        "${Endpoints.profile}/$userId${Endpoints.verifyCode}", 
        {"email": email, "code": code}
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
