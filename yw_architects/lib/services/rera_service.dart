import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';

class ReraService {
  static const String baseUrl = "${ApiConstants.baseUrl}/rera";

  /// Create a new RERA project
  /// POST /api/rera/project/{projectId}
  static Future<bool> createReraProject({
    required int projectId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final token = TokenService.accessToken;
      
      final uri = Uri.parse("$baseUrl/project/$projectId");
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      debugPrint("CREATE RERA STATUS: ${response.statusCode}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("CREATE RERA BODY: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("CREATE RERA ERROR: $e");
      return false;
    }
  }

  /// Get RERA details by project
  /// GET /api/rera/project/{projectId}
  static Future<List<dynamic>> getReraByProjectId(int projectId) async {
    try {
      final token = TokenService.accessToken;
      final response = await http.get(
        Uri.parse("$baseUrl/project/$projectId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? [];
      } else {
        debugPrint("GET RERA ERROR: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("GET RERA EXCEPTION: $e");
      return [];
    }
  }

  /// Delete a RERA project
  /// DELETE /api/rera/{reraId}
  static Future<bool> deleteReraProject(int reraId) async {
    try {
      final token = TokenService.accessToken;
      final response = await http.delete(
        Uri.parse("$baseUrl/$reraId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      debugPrint("DELETE RERA STATUS: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("DELETE RERA ERROR: $e");
      return false;
    }
  }
}
