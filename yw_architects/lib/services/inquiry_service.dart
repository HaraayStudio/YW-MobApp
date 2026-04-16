import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api/constants.dart';
import 'token_service.dart';

class InquiryService {
  static String get baseUrl => "${ApiConstants.baseUrl}/presales";

  static Map<String, String> get _authHeaders => {"Authorization": "Bearer ${TokenService.accessToken}"};
  static Map<String, String> get _jsonHeaders => {
    "Authorization": "Bearer ${TokenService.accessToken}",
    "Content-Type": "application/json",
  };

  static Future<http.Response> _resilientGet(Uri url, Map<String, String> h) async {
    final c = http.Client();
    try {
      final req = http.Request('GET', url)..headers.addAll(h)..followRedirects = false;
      return await http.Response.fromStream(await c.send(req).timeout(const Duration(seconds: 15)));
    } finally { c.close(); }
  }

  static Future<http.Response> _resilientPost(Uri url, Map<String, String> h, dynamic body) async {
    final c = http.Client();
    try {
      final req = http.Request('POST', url)..headers.addAll(h)..followRedirects = false;
      if (body != null) req.body = body is String ? body : jsonEncode(body);
      return await http.Response.fromStream(await c.send(req).timeout(const Duration(seconds: 15)));
    } finally { c.close(); }
  }

  static Future<http.Response> _resilientPut(Uri url, Map<String, String> h, dynamic body) async {
    final c = http.Client();
    try {
      final req = http.Request('PUT', url)..headers.addAll(h)..followRedirects = false;
      if (body != null) req.body = body is String ? body : jsonEncode(body);
      return await http.Response.fromStream(await c.send(req).timeout(const Duration(seconds: 15)));
    } finally { c.close(); }
  }

  static Future<http.Response> _resilientDelete(Uri url, Map<String, String> h) async {
    final c = http.Client();
    try {
      final req = http.Request('DELETE', url)..headers.addAll(h)..followRedirects = false;
      return await http.Response.fromStream(await c.send(req).timeout(const Duration(seconds: 15)));
    } finally { c.close(); }
  }

  // GET /api/presales/getall
  static Future<List<dynamic>> getAllInquiries() async {
    final token = TokenService.accessToken;
    try {
      final response = await _resilientGet(
        Uri.parse("$baseUrl/getall"),
        _authHeaders,
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
    try {
      final response = await _resilientPost(
        Uri.parse("$baseUrl/create?existingClient=$existingClient"),
        _jsonHeaders,
        payload,
      );
      debugPrint("CREATE INQUIRY STATUS: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("CREATE INQUIRY ERROR: $e");
      return false;
    }
  }

  // PUT /api/presales/update/{srNumber}
  static Future<bool> updateInquiry(int srNumber, Map<String, dynamic> payload) async {
    try {
      final response = await _resilientPut(
        Uri.parse("$baseUrl/update/$srNumber"),
        _jsonHeaders,
        payload,
      );
      debugPrint("UPDATE INQUIRY STATUS: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("UPDATE INQUIRY ERROR: $e");
      return false;
    }
  }

  // DELETE /api/presales/delete/{srNumber}
  static Future<bool> deleteInquiry(int srNumber) async {
    try {
      final response = await _resilientDelete(
        Uri.parse("$baseUrl/delete/$srNumber"),
        _authHeaders,
      );
      debugPrint("DELETE INQUIRY STATUS: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 204;
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
