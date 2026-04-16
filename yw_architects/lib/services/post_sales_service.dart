import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import 'package:http_parser/http_parser.dart';
import '../api/constants.dart';

class PostSalesService {
  static String get baseUrl => "${ApiConstants.baseUrl}/postsales";

  /// Creates a new Post-Sale record (which creates a Project).
  /// [isOldClient] should be true if linking to an existing client ID.
  /// [payload] should contain project/post-sale details and client info.
  /// [logoBytes] optional logo file bytes.
  static Future<Map<String, dynamic>> createPostSale({
    required Map<String, dynamic> payload,
    required bool isOldClient,
    List<int>? logoBytes,
    String? logoName,
  }) async {
    final token = TokenService.accessToken;
    final uri = Uri.parse("$baseUrl/createpostSales?isOldClient=$isOldClient");

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer $token";

    // Add JSON payload as a part named 'postSale' (or whatever the backend expects)
    // Looking at the updateProject, it uses 'project'. 
    // Usually for createPostSales it might be 'postSale' or just parameters.
    // However, if the service previously used jsonEncode(payload), 
    // we send it as a 'payload' part or similar.
    request.files.add(http.MultipartFile.fromString(
      'postSale', // Adjust if backend expects a different part name
      jsonEncode(payload),
      contentType: MediaType('application', 'json'),
    ));

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
      
      print("CREATE POST-SALE STATUS: ${response.statusCode}");
      print("CREATE POST-SALE BODY: ${response.body}");

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
    } catch (e) {
      print("CREATE POST-SALE ERROR: $e");
      return {
        "success": false,
        "message": "Connection error: $e",
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
      final uri = Uri.parse("$baseUrl/project/$projectId");
      debugPrint("API REQUEST: GET $uri");

      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      debugPrint("GET POST-SALE STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // FLEX-PARSE: Check for data wrapper, otherwise use top-level
        final dynamic rawPayload = (decoded is Map && decoded.containsKey('data')) 
            ? decoded['data'] 
            : decoded;

        if (rawPayload != null) {
          if (rawPayload is Map && (rawPayload.containsKey('projectId') || rawPayload.containsKey('postSalesStatus'))) {
            // CASE 1: Data is the record itself
            return rawPayload as Map<String, dynamic>;
          } else if (rawPayload is List && rawPayload.isNotEmpty) {
            // CASE 2: Data is a list
            return rawPayload.first as Map<String, dynamic>;
          } else if (rawPayload is Map &&
              rawPayload['content'] != null &&
              (rawPayload['content'] as List).isNotEmpty) {
            // CASE 3: PageImpl
            return rawPayload['content'].first as Map<String, dynamic>;
          } else if (rawPayload is Map && rawPayload.isNotEmpty) {
            // CASE 4: Direct Map fallback
            return rawPayload as Map<String, dynamic>;
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
