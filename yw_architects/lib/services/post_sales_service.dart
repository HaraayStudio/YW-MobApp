import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';

class PostSalesService {
  static const String baseUrl = "${ApiConstants.baseUrl}/postsales";

  /// Creates a new Post-Sale record (which creates a Project).
  /// [isOldClient] should be true if linking to an existing client ID.
  /// [payload] should contain project/post-sale details and client info.
  static Future<Map<String, dynamic>> createPostSale({
    required Map<String, dynamic> payload,
    required bool isOldClient,
  }) async {
    final token = TokenService.accessToken;

    final response = await http.post(
      Uri.parse("$baseUrl/createpostSales?isOldClient=$isOldClient"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    print("CREATE POST-SALE STATUS: ${response.statusCode}");
    
    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        "success": true,
        "data": decoded['data'],
      };
    } else {
      return {
        "success": false,
        "message": decoded['message'] ?? "Failed to create project record",
      };
    }
  }

  /// Fetches all Post-Sale records.
  static Future<List<dynamic>> getAllPostSales() async {
    final token = TokenService.accessToken;

    final response = await http.get(
      Uri.parse("$baseUrl/getall"), // Corrected from /getallpostsales
      headers: {"Authorization": "Bearer $token"},
    );

    print("GET ALL PROJECTS STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    }
    return [];
  }
}
