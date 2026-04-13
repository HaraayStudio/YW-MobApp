import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api/constants.dart';
import 'token_service.dart';

class InquiryService {
  static const String baseUrl = "${ApiConstants.baseUrl}/presales";

  // GET /api/presales/getall
  static Future<List<dynamic>> getAllInquiries() async {
    final token = TokenService.accessToken;
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/getall"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? [];
      }
    } catch (e) {
      debugPrint("FETCH INQUIRIES ERROR: $e");
    }
    return [];
  }

  // POST /api/presales/create?existingClient=true|false
  static Future<bool> createInquiry(Map<String, dynamic> payload, bool existingClient) async {
    final token = TokenService.accessToken;
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/create?existingClient=$existingClient"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("CREATE INQUIRY ERROR: $e");
      return false;
    }
  }

  // DELETE /api/presales/delete/{srNumber}
  static Future<bool> deleteInquiry(int srNumber) async {
    final token = TokenService.accessToken;
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/delete/$srNumber"),
        headers: {"Authorization": "Bearer $token"},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("DELETE INQUIRY ERROR: $e");
      return false;
    }
  }

  // PUT /api/presales/updateStatus/{srNumber}/{status}
  // Note: Based on web logic, it might take srNumber and status
  static Future<bool> updateStatus(int srNumber, String status) async {
    final token = TokenService.accessToken;
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/updateStatus/$srNumber/$status"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("UPDATE STATUS ERROR: $e");
      return false;
    }
  }

  // POST /api/postsales/converttopostSales?preSalesId={id}
  static Future<bool> convertToProject(int preSalesId) async {
    final token = TokenService.accessToken;
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/postsales/converttopostSales?preSalesId=$preSalesId"),
        headers: {"Authorization": "Bearer $token"},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("CONVERT TO PROJECT ERROR: $e");
      return false;
    }
  }
}
