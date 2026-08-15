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

  Future<List<Map<String, dynamic>>> getUserGadgets(int userId) async {
    try {
      final response = await _apiClient.get("${Endpoints.profile}/$userId/gadgets");
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDefenseGadgets(int userId) async {
    try {
      final response = await _apiClient.get("${Endpoints.profile}/$userId/gadgets");
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // On filtre strictement sur le type 'DEFENSE' renvoyé par le backend
        return data
            .where((g) => g['type'] == 'DEFENSE')
            .cast<Map<String, dynamic>>()
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> updateAvatar(int userId, String avatarUrl) async {
    try {
      final response = await _apiClient.post(
        "${Endpoints.profile}/$userId/update-avatar", 
        {"avatar": avatarUrl}
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getOwnedAvatars(int userId) async {
    try {
      final response = await _apiClient.get("${Endpoints.profile}/$userId/owned-avatars");
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final response = await _apiClient.get(Endpoints.leaderboard);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendVerificationCode(int userId, String email) async {
    try {
      final response = await _apiClient.post("${Endpoints.profile}/$userId/send-verification-code", {"email": email});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyCodeAndUpdateEmail(int userId, String email, String code) async {
    try {
      final response = await _apiClient.post("${Endpoints.profile}/$userId/verify-code", {
        "email": email,
        "code": code,
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
