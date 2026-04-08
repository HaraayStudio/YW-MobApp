import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import 'package:http_parser/http_parser.dart';
import '../api/constants.dart';
import 'package:flutter/foundation.dart';

class ProjectService {
  static const String baseUrl = "${ApiConstants.baseUrl}/projects";

  // POST /api/projects/createproject
  static Future<bool> createProject(Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;

    final response = await http.post(
      Uri.parse("$baseUrl/createproject"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    print("CREATE PROJECT STATUS: ${response.statusCode}");
    if (response.statusCode != 200 && response.statusCode != 201) {
      print("CREATE PROJECT BODY: ${response.body}");
    }
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // GET /api/projects/getallprojects
  static Future<List<dynamic>> getAllProjects({
    int page = 0,
    int size = 100,
  }) async {
    final token = TokenService.accessToken;

    final response = await http.get(
      Uri.parse("$baseUrl/getallprojects?page=$page&size=$size"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("GET ALL PROJECTS STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    }
    return [];
  }

  // GET /api/projects/{projectId}
  static Future<Map<String, dynamic>?> getProjectById(int projectId) async {
    final token = TokenService.accessToken;
    final client = http.Client();
    
    try {
      final url = Uri.parse("$baseUrl/$projectId");
      debugPrint("API REQUEST: GET $url");
      
      final request = http.Request('GET', url)
        ..headers['Authorization'] = "Bearer $token"
        ..headers['Accept'] = "application/json"
        ..headers['Cache-Control'] = "no-cache"
        ..followRedirects = true;
      
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      print("GET PROJECT $projectId STATUS: ${response.statusCode}");
      if (response.statusCode >= 300 && response.statusCode < 400) {
        print("REDIRECT DETECTED: ${response.headers['location']}");
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print("ERROR FETCHING PROJECT BY ID: $e");
    } finally {
      client.close();
    }
    return null;
  }

  // PUT /api/projects/{projectId}/status
  static Future<bool> updateProjectStatus(int projectId, String status) async {
    final token = TokenService.accessToken;

    final response = await http.put(
      Uri.parse("$baseUrl/$projectId/status"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"status": status}),
    );

    print("UPDATE PROJECT STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // PUT /api/projects/{projectId} (Multipart)
  static Future<bool> updateProject(int projectId, Map<String, dynamic> projectData, {List<int>? logoBytes, String? logoName}) async {
    final token = TokenService.accessToken;
    final uri = Uri.parse("$baseUrl/$projectId");

    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = "Bearer $token";

    // "project" part as JSON Blob
    final projectPart = http.MultipartFile.fromString(
      'project',
      jsonEncode(projectData),
      contentType: MediaType('application', 'json'),
    );
    request.files.add(projectPart);

    // "logo" part as file
    if (logoBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'logo',
        logoBytes,
        filename: logoName ?? 'logo.png',
        contentType: MediaType('image', logoName?.split('.').last ?? 'png'),
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("UPDATE MULTIPART PROJECT ${response.statusCode}: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("MULTIPART UPDATE ERROR: $e");
      return false;
    }
  }
}
