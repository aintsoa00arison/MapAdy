import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'endpoints.dart';

class ShopService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>?> getGadgets() async {
    try {
      final response = await _apiClient.get(Endpoints.shopGadgets);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>?> getAvatars() async {
    try {
      final response = await _apiClient.get(Endpoints.shopAvatars);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> purchaseItem(int userId, int itemId, String category) async {
    try {
      final response = await _apiClient.post("/shop/purchase", {
        "user_id": userId,
        "item_id": itemId,
        "category": category
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      debugPrint("🛒 PURCHASE FAILED: Status ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      debugPrint("🛒 PURCHASE ERROR: $e");
      return null;
    }
  }

  Future<List<dynamic>?> getUserGadgets(int userId) async {
    try {
      final response = await _apiClient.get("${Endpoints.profile}/$userId${Endpoints.userGadgets}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
