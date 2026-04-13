import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';

class SiteVisitService {
  static const String baseUrl = "${ApiConstants.baseUrl}/site-visits";

  /// Creates a site visit. Uses `http.MultipartRequest` because the backend
  /// expects `multipart/form-data` due to the optional photo/document attachments.
  static Future<bool> createSiteVisit({
    required int projectId,
    required String title,
    required String description,
    required String locationNote,
    required DateTime visitDateTime,
  }) async {
    try {
      final token = TokenService.accessToken;
      var uri = Uri.parse(baseUrl);
      var request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['projectId'] = projectId.toString();
      request.fields['title'] = title;
      if (description.isNotEmpty) {
        request.fields['description'] = description;
      }
      if (locationNote.isNotEmpty) {
        request.fields['locationNote'] = locationNote;
      }
      
      // Backend format is typically ISO-8601 e.g. "2023-10-31T10:30:00"
      request.fields['visitDateTime'] = visitDateTime.toIso8601String();

      // We are leaving the 'photos' and 'documents' fields empty for now as requested.

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      debugPrint("CREATE SITE VISIT STATUS: ${response.statusCode}");
      debugPrint("CREATE SITE VISIT BODY:   $responseData");
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("CREATE SITE VISIT ERROR: $e");
      return false;
    }
  }
}
