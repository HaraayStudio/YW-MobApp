import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import 'package:http_parser/http_parser.dart';
import '../api/constants.dart';
import 'package:flutter/foundation.dart';

class ProjectService {
  static const String baseUrl = "${ApiConstants.baseUrl}/projects";

  /// Resilient HTTP helpers to prevent 3xx-no-Location crashes
  static Future<http.Response> _resilientGet(Uri url, Map<String, String> headers) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', url)..headers.addAll(headers)..followRedirects = false;
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamedResponse);
    } finally { client.close(); }
  }

  static Future<http.Response> _resilientPost(Uri url, Map<String, String> headers, dynamic body) async {
    final client = http.Client();
    try {
      final request = http.Request('POST', url)..headers.addAll(headers)..followRedirects = false;
      if (body != null) {
        if (body is String) { request.body = body; }
        else { request.body = jsonEncode(body); }
      }
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamedResponse);
    } finally { client.close(); }
  }

  static Future<http.Response> _resilientPut(Uri url, Map<String, String> headers, dynamic body) async {
    final client = http.Client();
    try {
      final request = http.Request('PUT', url)..headers.addAll(headers)..followRedirects = false;
      if (body != null) {
        if (body is String) { request.body = body; }
        else { request.body = jsonEncode(body); }
      }
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamedResponse);
    } finally { client.close(); }
  }

  // POST /api/projects/createproject
  static Future<bool> createProject(Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;

    final response = await _resilientPost(
      Uri.parse("$baseUrl/createproject"),
      {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      payload,
    );

    print("CREATE PROJECT STATUS: ${response.statusCode}");
    if (response.statusCode != 200 && response.statusCode != 201) {
      print("CREATE PROJECT BODY: ${response.body}");
    }
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // PUT /api/projects/addusers/{projectId}
  static Future<bool> addUsersToProject(int projectId, List<int> userIds) async {
    final token = TokenService.accessToken;

    try {
      final response = await _resilientPut(
        Uri.parse("$baseUrl/addusers/$projectId"),
        {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        userIds,
      );

      debugPrint("ADD USERS TO PROJECT STATUS: ${response.statusCode}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("ADD USERS TO PROJECT BODY: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("ADD USERS TO PROJECT ERROR: $e");
      return false;
    }
  }

  // GET /api/projects/getallprojects
  static Future<List<dynamic>> getAllProjects({
    int page = 0,
    int size = 100,
  }) async {
    final token = TokenService.accessToken;

    final response = await _resilientGet(
      Uri.parse("$baseUrl/getallprojects?page=$page&size=$size"),
      {"Authorization": "Bearer $token"},
    );

    print("GET ALL PROJECTS STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getProjectById(int projectId) async {
    final token = TokenService.accessToken;
    final client = http.Client();
    try {
      final url = Uri.parse("$baseUrl/$projectId");
      final response = await _resilientGet(url, {
        'Authorization': "Bearer $token",
        'Accept': "application/json",
      });

      print("GET PROJECT $projectId STATUS: ${response.statusCode}");
      
      // Since React accepts 302 as success, we'll parse JSON on 200...399
      if (response.statusCode >= 200 && response.statusCode < 400) {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          return decoded['data'] as Map<String, dynamic>?;
        }
      } else {
        debugPrint("GET PROJECT FAILED: ${response.body}");
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

    final response = await _resilientPut(
      Uri.parse("$baseUrl/$projectId/status"),
      {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      {"status": status},
    );

    print("UPDATE PROJECT STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // PUT /api/projects/{projectId} (Multipart)
  // This endpoint accepts a JSON part "project" and an optional file part "logo".
  // If "logo" part is null, the backend will treat "logoUrl" inside "project" as the source.
  static Future<bool> updateProject(int projectId, Map<String, dynamic> projectData, {List<int>? logoBytes, String? logoName}) async {
    final token = TokenService.accessToken;
    final uri = Uri.parse("$baseUrl/$projectId");

    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = "Bearer $token";

    // Ensure the projectData contains the logoUrl if provided via Base64
    final jsonPart = http.MultipartFile.fromString(
      'project',
      jsonEncode(projectData),
      contentType: MediaType('application', 'json'),
    );
    request.files.add(jsonPart);

    // If logoBytes is null, the backend is expected to use the logoUrl from the JSON part
    if (logoBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'logo',
        logoBytes,
        filename: logoName ?? 'logo.png',
        contentType: MediaType('image', logoName?.split('.').last ?? 'png'),
      ));
    }

    try {
      request.followRedirects = false;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("UPDATE PROJECT ${response.statusCode}: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("PROJECT UPDATE ERROR: $e");
      return false;
    }
  }
}
