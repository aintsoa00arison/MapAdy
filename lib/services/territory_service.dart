import 'dart:convert';
import 'api_client.dart';
import 'endpoints.dart';

class TerritoryService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getAllBases() async {
    try {
      final response = await _apiClient.get(Endpoints.bases);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOwnedBases(int userId) async {
    try {
      final response = await _apiClient.get(Endpoints.bases);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .where((b) => b['owner_id'] == userId)
            .cast<Map<String, dynamic>>()
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> activateDefense(int baseId, int userId, int gadgetId) async {
    try {
      final response = await _apiClient.post("/bases/$baseId/activate-defense", {
        "user_id": userId,
        "gadget_id": gadgetId,
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
