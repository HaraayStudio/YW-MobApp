import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api/constants.dart';
import 'token_service.dart';

class QuotationService {
  static const String baseUrl = "${ApiConstants.baseUrl}/quotations";

  static Map<String, String> get _headers => {
        "Authorization": "Bearer ${TokenService.accessToken}",
        "Content-Type": "application/json",
      };

  static Map<String, String> get _authHeaders => {
        "Authorization": "Bearer ${TokenService.accessToken}",
      };

  // ── Resilient HTTP helpers ──────────────────────────────────────────────────
  static Future<http.Response> _resilientGet(Uri url, Map<String, String> headers) async {
    final client = http.Client();
    try {
      final req = http.Request('GET', url)
        ..headers.addAll(headers)
        ..followRedirects = false;
      final streamed = await client.send(req).timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamed);
    } finally {
      client.close();
    }
  }

  static Future<http.Response> _resilientPost(Uri url, Map<String, String> headers, dynamic body) async {
    final client = http.Client();
    try {
      final req = http.Request('POST', url)
        ..headers.addAll(headers)
        ..followRedirects = false;
      if (body != null) req.body = body is String ? body : jsonEncode(body);
      final streamed = await client.send(req).timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamed);
    } finally {
      client.close();
    }
  }

  static Future<http.Response> _resilientPatch(Uri url, Map<String, String> headers) async {
    final client = http.Client();
    try {
      final req = http.Request('PATCH', url)
        ..headers.addAll(headers)
        ..followRedirects = false;
      final streamed = await client.send(req).timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamed);
    } finally {
      client.close();
    }
  }

  static Future<http.Response> _resilientDelete(Uri url, Map<String, String> headers) async {
    final client = http.Client();
    try {
      final req = http.Request('DELETE', url)
        ..headers.addAll(headers)
        ..followRedirects = false;
      final streamed = await client.send(req).timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamed);
    } finally {
      client.close();
    }
  }

  // ── GET quotations by pre-sale ID ────────────────────────────────────────────
  // GET /api/quotations/presales/{preSalesId}
  static Future<List<dynamic>> getQuotationsByPreSale(int preSalesId) async {
    try {
      final response = await _resilientGet(
        Uri.parse("$baseUrl/presales/$preSalesId"),
        _authHeaders,
      );
      debugPrint("GET QUOTATIONS (presale=$preSalesId) STATUS: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? decoded ?? [];
      }
    } catch (e) {
      debugPrint("GET QUOTATIONS ERROR: $e");
    }
    return [];
  }

  // ── CREATE quotation ──────────────────────────────────────────────────────────
  // POST /api/quotations/presales/{preSalesId}
  static Future<bool> createQuotation(int preSalesId, Map<String, dynamic> data) async {
    try {
      final response = await _resilientPost(
        Uri.parse("$baseUrl/presales/$preSalesId"),
        _headers,
        data,
      );
      debugPrint("CREATE QUOTATION STATUS: ${response.statusCode} | ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("CREATE QUOTATION ERROR: $e");
      return false;
    }
  }

  // ── DELETE quotation ──────────────────────────────────────────────────────────
  // DELETE /api/quotations/{id}
  static Future<bool> deleteQuotation(int id) async {
    try {
      final response = await _resilientDelete(
        Uri.parse("$baseUrl/$id"),
        _authHeaders,
      );
      debugPrint("DELETE QUOTATION STATUS: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("DELETE QUOTATION ERROR: $e");
      return false;
    }
  }

  // ── MARK as SENT ──────────────────────────────────────────────────────────────
  // PATCH /api/quotations/{id}/send
  static Future<bool> markAsSent(int id) async {
    try {
      final response = await _resilientPatch(
        Uri.parse("$baseUrl/$id/send"),
        _authHeaders,
      );
      debugPrint("MARK QUOTATION SENT STATUS: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("MARK SENT ERROR: $e");
      return false;
    }
  }

  // ── MARK as ACCEPTED ──────────────────────────────────────────────────────────
  // PATCH /api/quotations/{id}/accept
  static Future<bool> markAsAccepted(int id) async {
    try {
      final response = await _resilientPatch(
        Uri.parse("$baseUrl/$id/accept"),
        _authHeaders,
      );
      debugPrint("MARK QUOTATION ACCEPTED STATUS: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("MARK ACCEPTED ERROR: $e");
      return false;
    }
  }
}
