import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  // Récupération de l'URL avec nettoyage des espaces et des slashs finaux
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
    print("📦 [BODY] : ${jsonEncode(body)}");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      
      print("✅ [RESPONSE] ${response.statusCode} from $endpoint");
      return response;
    } on TimeoutException {
      print("⏰ [ERROR] Timeout : Le serveur Render est trop lent à répondre.");
      return http.Response(jsonEncode({"error": "Timeout"}), 408);
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
      ).timeout(const Duration(seconds: 15));
      
      print("✅ [RESPONSE] ${response.statusCode} from $endpoint");
      return response;
    } on TimeoutException {
      print("⏰ [ERROR] Timeout : Le serveur Render est trop lent.");
      return http.Response(jsonEncode({"error": "Timeout"}), 408);
    } catch (e) {
      print("❌ [CRITICAL ERROR] GET $endpoint : $e");
      return http.Response(jsonEncode({"error": e.toString()}), 500);
    }
  }
}
