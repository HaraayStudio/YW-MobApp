import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';


class EmployeeService {
  //static const String baseUrl = "http://localhost:8080/api/employees";
  //static const String baseUrl = "http://10.0.2.2:8080/api/employees";
  static String get baseUrl => "${ApiConstants.baseUrl}/employees";

  /// Resilient HTTP helpers that don't crash on redirects (3xx without Location)
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
  // ── POST /api/employees/createemployee ────────────────────────────────────
  // Spring: @PostMapping("/createemployee") @RequestBody User user
  // Pass _buildPayload() directly from the Add Employee modal
  static Future<bool> createEmployee(Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;

    final response = await http.post(
      Uri.parse("$baseUrl/createemployee"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    print("CREATE EMPLOYEE STATUS: ${response.statusCode}");
    print("CREATE EMPLOYEE BODY:   ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ── GET /api/employees/getallemployees ────────────────────────────────────
  // Spring: @GetMapping("/getallemployees")
  // Returns list from ResponseStructure.data
  static Future<List<dynamic>> getAllEmployees() async {
    final token = TokenService.accessToken;

    final response = await _resilientGet(
      Uri.parse("$baseUrl/getallemployees"),
      {"Authorization": "Bearer $token"},
    );

    print("GET ALL EMPLOYEES STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    }
    return [];
  }

  // ── PUT /api/employees/updateemployee?id= ─────────────────────────────────
  // Spring: @PutMapping("/updateemployee") @RequestParam Long id @RequestBody User
  static Future<bool> updateEmployee(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final token = TokenService.accessToken;

    final response = await _resilientPut(
      Uri.parse("$baseUrl/updateemployee?id=$id"),
      {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      payload,
    );

    print("UPDATE EMPLOYEE STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ── DELETE /api/employees/deleteemployee?id= ──────────────────────────────
  // Spring: @DeleteMapping("/deleteemployee") @RequestParam Long id
  // Soft delete — marks employee inactive, does not remove from DB
  static Future<bool> deleteEmployee(int id) async {
    final token = TokenService.accessToken;

    final response = await http.delete(
      Uri.parse("$baseUrl/deleteemployee?id=$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("DELETE EMPLOYEE STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ── DELETE /api/employees/activeemployee?id= ──────────────────────────────
  // Spring: @DeleteMapping("/activeemployee") @RequestParam Long id
  // Marks employee as ACTIVE
  static Future<bool> activateEmployee(int id) async {
    final token = TokenService.accessToken;

    final response = await http.delete(
      Uri.parse("$baseUrl/activeemployee?id=$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("ACTIVATE EMPLOYEE STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ── GET /api/employees/getmyprojects ──────────────────────────────────────
  // Spring: @GetMapping("/getmyprojects") with pagination
  static Future<List<dynamic>> getMyProjects({
    int page = 0,
    int size = 10,
  }) async {
    final token = TokenService.accessToken;

    final response = await _resilientGet(
      Uri.parse("$baseUrl/getmyprojects?page=$page&size=$size"),
      {"Authorization": "Bearer $token"},
    );

    print("GET MY PROJECTS STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    }
    return [];
  }

  // ── PUT /api/employees/updatemypassword ───────────────────────────────────
  // Spring: @PutMapping("/updatemypassword") @RequestParam oldPassword, newPassword
  static Future<bool> updateMyPassword(
    String oldPassword,
    String newPassword,
  ) async {
    final token = TokenService.accessToken;

    final response = await _resilientPut(
      Uri.parse("$baseUrl/updatemypassword?oldPassword=$oldPassword&newPassword=$newPassword"),
      {"Authorization": "Bearer $token"},
      null,
    );

    print("UPDATE PASSWORD STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ── PUT /api/employees/updatemyprofile ─────────────────────────────────────
  // Spring: @PutMapping("/updatemyprofile") @RequestBody User employee
  static Future<bool> updateMyProfile(Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;

    // The backend User model has a 'profileImage' field.
    // If the payload contains a Base64 string here, the database will store it directly.
    final response = await _resilientPut(
      Uri.parse("$baseUrl/updatemyprofile"),
      {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      payload,
    );

    print("UPDATE MY PROFILE STATUS: ${response.statusCode}");
    if (response.statusCode != 200 && response.statusCode != 201) {
      print("UPDATE MY PROFILE ERROR: ${response.body}");
    }
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ── PUT /api/employees/updatemyprofileimage ────────────────────────────────
  // Spring: @PutMapping(consumes = MULTIPART_FORM_DATA_VALUE)
  static Future<bool> updateMyProfileImage(String filePath) async {
    final token = TokenService.accessToken;

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse("$baseUrl/updatemyprofileimage"),
    );

    request.headers['Authorization'] = "Bearer $token";
    request.files.add(
      await http.MultipartFile.fromPath('profileimage', filePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("UPDATE PROFILE IMAGE STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ── GET /api/employees/getemployeedata ────────────────────────────────────
  // Spring: @GetMapping("/getemployeedata")
  // Returns current logged-in employee details
  static Future<Map<String, dynamic>?> getEmployeeData() async {
    final token = TokenService.accessToken;

    final response = await _resilientGet(
      Uri.parse("$baseUrl/getemployeedata"),
      {"Authorization": "Bearer $token"},
    );

    print("GET EMPLOYEE DATA STATUS: ${response.statusCode}");
    print("GET EMPLOYEE DATA BODY:   ${response.body}");
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print("GET EMPLOYEE DATA DECODED: $decoded");
      return decoded['data'] as Map<String, dynamic>?;
    }
    return null;
  }
}
