import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';
import '../models/site_model.dart';

class SiteService {
  // Use /projects to align with web backend
  static String get baseUrl => "${ApiConstants.baseUrl}/projects";

  /// GET /api/projects/getallprojects (Paginated Site List)
  static Future<List<Site>> getSites({int page = 0, int size = 100}) async {
    final token = TokenService.accessToken;
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/getallprojects?page=$page&size=$size"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        List<dynamic> data = [];
        if (decoded['data'] is List) {
          data = decoded['data'];
        } else if (decoded['data'] is Map && decoded['data']['content'] is List) {
          data = decoded['data']['content'];
        }

        return data.map((item) => Site.fromJson(item)).toList();
      }
    } catch (e) {
      print("ERROR FETCHING PROJECTS: $e");
    }
    return [];
  }

  /// GET /api/projects/{id} (Site Detail)
  static Future<Site?> getSiteById(int id) async {
    final token = TokenService.accessToken;
    final client = http.Client();
    try {
      Uri currentUri = Uri.parse("$baseUrl/$id");
      int redirectCount = 0;
      const int maxRedirects = 2; // Follow up to 2 times

      while (redirectCount <= maxRedirects) {
        debugPrint(redirectCount == 0 
            ? "API REQUEST: GET $currentUri" 
            : "[REDIRECT FOLLOWED] $currentUri");

        final request = http.Request('GET', currentUri)
          ..headers['Authorization'] = 'Bearer $token'
          ..followRedirects = false;

        final streamedResponse = await client.send(request);
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint("STATUS: ${response.statusCode}");

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final dynamic rawPayload = (decoded is Map && decoded.containsKey('data')) 
              ? decoded['data'] 
              : decoded;

          if (rawPayload != null && rawPayload is Map) {
            return Site.fromJson(rawPayload as Map<String, dynamic>);
          }
          return null;
        } else if (response.statusCode >= 300 && response.statusCode < 400) {
          final location = response.headers['location'];
          if (location != null && location.isNotEmpty) {
            // Handle relative redirects
            if (location.startsWith('/')) {
              currentUri = Uri.parse("${currentUri.origin}$location");
            } else {
              currentUri = Uri.parse(location);
            }
            redirectCount++;
          } else {
            debugPrint("!!! REDIRECT WITHOUT LOCATION HEADER !!!");
            break;
          }
        } else {
          debugPrint("RESPONSE BODY: ${response.body}");
          break;
        }
      }
    } catch (e) {
      debugPrint("ERROR FETCHING PROJECT BY ID: $e");
    } finally {
      client.close();
    }
    return null;
  }

  /// POST /api/projects (Create Site)
  static Future<bool> createSite(Map<String, dynamic> data) async {
    final token = TokenService.accessToken;
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERROR CREATING PROJECT: $e");
      return false;
    }
  }

  /// PUT /api/projects/{id}/status (Update status)
  static Future<bool> updateStatus(int id, String status) async {
    final token = TokenService.accessToken;
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id/status"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
