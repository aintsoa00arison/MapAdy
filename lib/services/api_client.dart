import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  String get baseUrl {
    String url = dotenv.env['BASE_URL'] ?? "https://mapady.onrender.com/api";
    url = url.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = "$baseUrl$cleanEndpoint";
    
    print("📡 [OUTGOING] POST : $fullUrl");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60)); // Augmenté à 60s pour Render Free
      
      print("✅ [RESPONSE] ${response.statusCode} from $endpoint");
      return response;
    } on TimeoutException {
      print("⏰ [TIMEOUT] Le serveur Render se réveille, réessayez dans quelques secondes...");
      return http.Response(jsonEncode({"error": "Le serveur met trop de temps à répondre (Cold Start)"}), 408);
    } catch (e) {
      print("❌ [CRITICAL ERROR] POST $endpoint : $e");
      return http.Response(jsonEncode({"error": e.toString()}), 500);
    }
  }

  Future<http.Response> get(String endpoint) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = "$baseUrl$cleanEndpoint";
    
    print("📡 [OUTGOING] GET : $fullUrl");

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 60)); // Augmenté à 60s
      
      print("✅ [RESPONSE] ${response.statusCode} from $endpoint");
      return response;
    } on TimeoutException {
      print("⏰ [TIMEOUT] Le serveur Render est en cours de réveil...");
      return http.Response(jsonEncode({"error": "Timeout Render Free"}), 408);
    } catch (e) {
      print("❌ [CRITICAL ERROR] GET $endpoint : $e");
      return http.Response(jsonEncode({"error": e.toString()}), 500);
    }
  }
}
