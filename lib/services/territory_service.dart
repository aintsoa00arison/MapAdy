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
}
