import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_client.dart';
import 'endpoints.dart';

class UserSession {
  static final ValueNotifier<int> goldNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<Map<String, dynamic>?> userNotifier = ValueNotifier<Map<String, dynamic>?>(null);
  
  static void updateGold(int newGold) {
    goldNotifier.value = newGold;
  }

  static void setUser(Map<String, dynamic>? user) {
    userNotifier.value = user;
    if (user != null) {
      goldNotifier.value = user['gold'] ?? 0;
    }
  }
}

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
    if (userJson != null) {
      final user = jsonDecode(userJson);
      UserSession.setUser(user);
      return user;
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      // On déconnecte seulement si nécessaire pour forcer le choix du compte
      // sinon on tente la connexion directe
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final response = await _apiClient.post(Endpoints.login, {"email": googleUser.email});

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await _saveSession(userData);
        return userData;
      }
      await _googleSignIn.signOut();
      return null;
    } catch (e) {
      await _googleSignIn.signOut();
      return null;
    }
  }

  Future<Map<String, dynamic>?> registerWithGoogle(String username) async {
    try {
      await _googleSignIn.signOut();
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
      await _googleSignIn.signOut();
      return null;
    } catch (e) {
      await _googleSignIn.signOut();
      return null;
    }
  }

  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(userData));
    UserSession.setUser(userData);
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(userKey);
      UserSession.setUser(null);
    } catch (e) {
      debugPrint("Erreur lors de la déconnexion: $e");
    }
  }
}
