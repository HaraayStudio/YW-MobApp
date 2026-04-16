import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';
import 'package:flutter/foundation.dart';

class StructureService {
  static String get baseUrl => "${ApiConstants.baseUrl}/structure";

  static Future<http.Response> _resilientPost(Uri url, Map<String, String> headers, dynamic body) async {
    final client = http.Client();
    try {
      final request = http.Request('POST', url)..headers.addAll(headers)..followRedirects = false;
      if (body != null) {
        if (body is String) {
          request.body = body;
        } else {
          request.body = jsonEncode(body);
        }
      }
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamedResponse);
    } finally {
      client.close();
    }
  }

  /// POST /api/structure/createstructure/{projectId}
  static Future<bool> createStructure(int projectId, Map<String, dynamic> structureData) async {
    final token = TokenService.accessToken;
    final uri = Uri.parse("$baseUrl/createstructure/$projectId");

    try {
      final response = await _resilientPost(
        uri,
        {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        structureData,
      );

      debugPrint("CREATE STRUCTURE STATUS: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint("CREATE STRUCTURE FAILED: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("CREATE STRUCTURE ERROR: $e");
      return false;
    }
  }
}
