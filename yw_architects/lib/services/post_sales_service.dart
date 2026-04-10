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

  /// Fetches a single Post-Sale record by Project ID (includes client, project, invoices, payments).
  static Future<Map<String, dynamic>?> getPostSaleByProjectId(int projectId) async {
    final token = TokenService.accessToken;

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/project/$projectId"),
        headers: {"Authorization": "Bearer $token"},
      );

      print("GET POST-SALE BY PROJECT ID STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        
        // The endpoint returns a paginated list or array. We take the first element if available.
        if (data != null) {
           if (data is List && data.isNotEmpty) {
             return data.first;
           } else if (data is Map && data['content'] != null && (data['content'] as List).isNotEmpty) {
             // Handle PageImpl structure if paginated
             return data['content'].first;
           }
        }
      }
      return null;
    } catch (e) {
      print("ERROR FETCHING POST SALE BY PROJECT ID: $e");
      return null;
    }
  }
  static Future<Map<String, dynamic>> addTaxInvoice(int postSalesId, Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;
    final response = await http.post(
      Uri.parse("$baseUrl/$postSalesId/tax-invoices"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true};
    } else {
      return {"success": false, "message": "Failed to create tax invoice"};
    }
  }

  static Future<Map<String, dynamic>> addProformaInvoice(int postSalesId, Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;
    final response = await http.post(
      Uri.parse("$baseUrl/$postSalesId/proforma-invoices"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true};
    } else {
      return {"success": false, "message": "Failed to create proforma invoice"};
    }
  }
}
