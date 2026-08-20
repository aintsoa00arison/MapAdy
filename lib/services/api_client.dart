import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
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
    
    debugPrint("📡 [OUTGOING] POST : $fullUrl");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60)); 
      
      debugPrint("✅ [RESPONSE] ${response.statusCode} from $endpoint");
      return response;
    } on TimeoutException {
      debugPrint("⏰ [TIMEOUT] Le serveur Render se réveille...");
      return http.Response(jsonEncode({"error": "Timeout Render Free"}), 408);
    } catch (e) {
      debugPrint("❌ [CRITICAL ERROR] POST $endpoint : $e");
      return http.Response(jsonEncode({"error": e.toString()}), 500);
    }
  }

  Future<http.Response> get(String endpoint) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = "$baseUrl$cleanEndpoint";
    
    debugPrint("📡 [OUTGOING] GET : $fullUrl");

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 60));
      
      debugPrint("✅ [RESPONSE] ${response.statusCode} from $endpoint");
      return response;
    } on TimeoutException {
      debugPrint("⏰ [TIMEOUT] Le serveur Render se réveille...");
      return http.Response(jsonEncode({"error": "Timeout Render Free"}), 408);
    } catch (e) {
      debugPrint("❌ [CRITICAL ERROR] GET $endpoint : $e");
      return http.Response(jsonEncode({"error": e.toString()}), 500);
    }
  }
}
