import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';

class ClientService {
  static const String baseUrl = "${ApiConstants.baseUrl}/clients";

  // POST /api/clients/createclient
  static Future<bool> createClient(Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;

    final response = await http.post(
      Uri.parse("$baseUrl/createclient"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    print("CREATE CLIENT STATUS: ${response.statusCode}");
    if (response.statusCode != 200 && response.statusCode != 201) {
      print("CREATE CLIENT BODY: ${response.body}");
    }
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // GET /api/clients/getallclients
  static Future<List<dynamic>> getAllClients() async {
    final token = TokenService.accessToken;

    final response = await http.get(
      Uri.parse("$baseUrl/getallclients"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("GET ALL CLIENTS STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    }
    return [];
  }

  // GET /api/clients/getclientbyid/{id}
  static Future<Map<String, dynamic>?> getClientById(int id) async {
    final token = TokenService.accessToken;

    final response = await http.get(
      Uri.parse("$baseUrl/getclientbyid/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  // PUT /api/clients/updateclient
  static Future<bool> updateClient(int id, Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;

    final response = await http.put(
      Uri.parse("$baseUrl/updateclient?id=$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    print("UPDATE CLIENT STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // DELETE /api/clients/deleteclient/{id}
  static Future<bool> deleteClient(int id) async {
    final token = TokenService.accessToken;

    final response = await http.delete(
      Uri.parse("$baseUrl/deleteclient/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("DELETE CLIENT STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
  }
}
