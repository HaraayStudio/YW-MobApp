import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';

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
  static Future<List<dynamic>> getAllProjects({int page = 0, int size = 100}) async {
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

    final response = await http.get(
      Uri.parse("$baseUrl/$projectId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] as Map<String, dynamic>?;
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
}
