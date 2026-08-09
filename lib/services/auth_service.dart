import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_client.dart';
import 'endpoints.dart';

class AuthService {
  static const String userKey = "mapady_user_session";
  final ApiClient _apiClient = ApiClient();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_CLIENT_ID'],
    scopes: ['email', 'profile'],
  );

  Future<Map<String, dynamic>?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(userKey);
    if (userJson != null) return jsonDecode(userJson);
    return null;
  }

  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final response = await _apiClient.post(Endpoints.login, {"email": googleUser.email});

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await _saveSession(userData);
        return userData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> registerWithGoogle(String username) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final response = await _apiClient.post(Endpoints.register, {
        "email": googleUser.email,
        "username": username,
      });

      if (response.statusCode == 201) {
        final userData = jsonDecode(response.body);
        await _saveSession(userData);
        return userData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(userData));
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _apiClient.post(Endpoints.logout, {});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(userKey);
    } catch (e) {
      // Logout failure
    }
  }
}
