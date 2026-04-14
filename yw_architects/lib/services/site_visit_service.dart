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
    List<String>? photoPaths,
    List<String>? documentPaths,
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
      
      request.fields['visitDateTime'] = visitDateTime.toIso8601String();

      // Add Photos
      if (photoPaths != null && photoPaths.isNotEmpty) {
        for (var path in photoPaths) {
          request.files.add(await http.MultipartFile.fromPath('photos', path));
        }
      }

      // Add Documents
      if (documentPaths != null && documentPaths.isNotEmpty) {
        for (var path in documentPaths) {
          request.files.add(await http.MultipartFile.fromPath('documents', path));
        }
      }

      var response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("CREATE SITE VISIT ERROR: $e");
      return false;
    }
  }

  /// Updates site visit basic info
  /// PUT /api/site-visits/{id}?title=...&description=...&visitDateTime=...&locationNote=...
  static Future<bool> updateSiteVisit({
    required int id,
    String? title,
    String? description,
    DateTime? visitDateTime,
    String? locationNote,
  }) async {
    try {
      final token = TokenService.accessToken;
      Map<String, String> params = {};
      if (title != null) params['title'] = title;
      if (description != null) params['description'] = description;
      if (visitDateTime != null) params['visitDateTime'] = visitDateTime.toIso8601String();
      if (locationNote != null) params['locationNote'] = locationNote;

      final uri = Uri.parse("$baseUrl/$id").replace(queryParameters: params);
      
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("UPDATE SITE VISIT STATUS: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("UPDATE SITE VISIT ERROR: $e");
      return false;
    }
  }

  /// Add photos to existing visit
  /// POST /api/site-visits/{id}/photos
  static Future<bool> addVisitPhotos(int visitId, List<String> photoPaths) async {
    try {
      final token = TokenService.accessToken;
      var uri = Uri.parse("$baseUrl/$visitId/photos");
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      for (var path in photoPaths) {
        request.files.add(await http.MultipartFile.fromPath('photos', path));
      }

      var response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("ADD PHOTOS ERROR: $e");
      return false;
    }
  }

  /// Add documents to existing visit
  /// POST /api/site-visits/{id}/documents
  static Future<bool> addVisitDocuments(int visitId, List<Map<String, String>> documentData) async {
    try {
      final token = TokenService.accessToken;
      var uri = Uri.parse("$baseUrl/$visitId/documents");
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      for (var doc in documentData) {
        final path = doc['path']!;
        final name = doc['name']!;
        request.files.add(await http.MultipartFile.fromPath('documents', path));
        request.fields['documentNames'] = name; // Note: check if backend supports multiple properly this way
      }

      var response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("ADD DOCUMENTS ERROR: $e");
      return false;
    }
  }

  /// Delete a photo from visit
  static Future<bool> deletePhoto(int visitId, int photoId) async {
    try {
      final token = TokenService.accessToken;
      final uri = Uri.parse("$baseUrl/$visitId/photos/$photoId");
      final response = await http.delete(uri, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("DELETE PHOTO ERROR: $e");
      return false;
    }
  }

  /// Delete a document from visit
  static Future<bool> deleteDocument(int visitId, int documentId) async {
    try {
      final token = TokenService.accessToken;
      final uri = Uri.parse("$baseUrl/$visitId/documents/$documentId");
      final response = await http.delete(uri, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("DELETE DOCUMENT ERROR: $e");
      return false;
    }
  }
}
