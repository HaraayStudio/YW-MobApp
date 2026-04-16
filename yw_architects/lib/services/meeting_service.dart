import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';

class MeetingService {
  static String get baseUrl => "${ApiConstants.baseUrl}/meetings";

  /// Create a new meeting linked to a project layout
  /// POST /api/meetings/create?projectId={projectId}&createdBy={createdBy}
  static Future<bool> createMeeting({
    required int projectId,
    required int createdBy,
    required Map<String, dynamic> meetingData,
  }) async {
    try {
      final token = TokenService.accessToken;
      
      final uri = Uri.parse("$baseUrl/create?projectId=$projectId&createdBy=$createdBy");
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(meetingData),
      );

      debugPrint("CREATE MEETING STATUS: ${response.statusCode}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("CREATE MEETING BODY: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("CREATE MEETING ERROR: $e");
      return false;
    }
  }

  /// Get meetings by project
  /// GET /api/meetings/project/{projectId}
  static Future<List<dynamic>> getMeetingsByProject(int projectId) async {
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
        debugPrint("GET MEETINGS ERROR: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("GET MEETINGS EXCEPTION: $e");
      return [];
    }
  }

  /// Update meeting
  /// PUT /api/meetings/update/{meetingId}
  static Future<bool> updateMeeting(int id, Map<String, dynamic> meetingData) async {
    try {
      final token = TokenService.accessToken;
      final response = await http.put(
        Uri.parse("$baseUrl/update/$id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(meetingData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("UPDATE MEETING ERROR: $e");
      return false;
    }
  }

  /// Delete meeting
  /// DELETE /api/meetings/delete/{meetingId}
  static Future<bool> deleteMeeting(int id) async {
    try {
      final token = TokenService.accessToken;
      final response = await http.delete(
        Uri.parse("$baseUrl/delete/$id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("DELETE MEETING ERROR: $e");
      return false;
    }
  }
}
