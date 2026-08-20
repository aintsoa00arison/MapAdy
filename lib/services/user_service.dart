import 'dart:convert';
import 'api_client.dart';
import 'endpoints.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiClient _apiClient = ApiClient();
  
  final Map<int, Map<String, dynamic>> _profileCache = {};
  final Map<int, DateTime> _cacheTime = {};

  Future<Map<String, dynamic>?> getProfile(int userId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _profileCache.containsKey(userId)) {
      final time = _cacheTime[userId];
      if (time != null && DateTime.now().difference(time).inSeconds < 10) {
        return _profileCache[userId];
      }
    }

    try {
      final response = await _apiClient.get("${Endpoints.profile}/$userId");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _profileCache[userId] = data;
        _cacheTime[userId] = DateTime.now();
        return data;
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
        final data = jsonDecode(response.body);
        _profileCache[userId] = data;
        return data;
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
        final data = jsonDecode(response.body);
        _profileCache[userId] = data;
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
