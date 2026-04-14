import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';


class EmployeeService {
  //static const String baseUrl = "http://localhost:8080/api/employees";
  //static const String baseUrl = "http://10.0.2.2:8080/api/employees";
  static const String baseUrl = "${ApiConstants.baseUrl}/employees";
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

    final response = await http.get(
      Uri.parse("$baseUrl/getallemployees"),
      headers: {"Authorization": "Bearer $token"},
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

    final response = await http.put(
      Uri.parse("$baseUrl/updateemployee?id=$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
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

    final response = await http.get(
      Uri.parse("$baseUrl/getmyprojects?page=$page&size=$size"),
      headers: {"Authorization": "Bearer $token"},
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

    final response = await http.put(
      Uri.parse(
        "$baseUrl/updatemypassword?oldPassword=$oldPassword&newPassword=$newPassword",
      ),
      headers: {"Authorization": "Bearer $token"},
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
    final response = await http.put(
      Uri.parse("$baseUrl/updatemyprofile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
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
}
