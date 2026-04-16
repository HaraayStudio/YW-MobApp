import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../api/constants.dart';

class InvoiceService {
  static String get _base => "${ApiConstants.baseUrl}/invoices";

  // ─── PROFORMA ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createProformaInvoice(
      int postSalesId, Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;
    final response = await http.post(
      Uri.parse("$_base/proforma/postsales/$postSalesId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );
    print("CREATE PROFORMA STATUS: ${response.statusCode} | BODY: ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return {"success": true, "data": decoded['data']};
    }
    return {"success": false, "message": "Failed (${response.statusCode}): ${response.body}"};
  }

  static Future<List<dynamic>> getProformasByPostSales(int postSalesId) async {
    final token = TokenService.accessToken;
    final response = await http.get(
      Uri.parse("$_base/proforma/postsales/$postSalesId"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    }
    return [];
  }

  static Future<bool> deleteProforma(int invoiceId) async {
    final token = TokenService.accessToken;
    final response = await http.delete(
      Uri.parse("$_base/proforma/$invoiceId"),
      headers: {"Authorization": "Bearer $token"},
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> convertToTax(int proformaId) async {
    final token = TokenService.accessToken;
    final response = await http.post(
      Uri.parse("$_base/proforma/$proformaId/convert"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return {"success": true, "data": decoded['data']};
    }
    return {"success": false, "message": "Conversion failed: ${response.body}"};
  }

  static Future<bool> markProformaPaid(int id) async {
    final token = TokenService.accessToken;
    final response = await http.patch(
      Uri.parse("$_base/proforma/$id/paid"),
      headers: {"Authorization": "Bearer $token"},
    );
    return response.statusCode == 200;
  }

  // ─── TAX INVOICE ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createTaxInvoice(
      int postSalesId, Map<String, dynamic> payload) async {
    final token = TokenService.accessToken;
    final response = await http.post(
      Uri.parse("$_base/tax/postsales/$postSalesId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );
    print("CREATE TAX INVOICE STATUS: ${response.statusCode} | BODY: ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return {"success": true, "data": decoded['data']};
    }
    return {"success": false, "message": "Failed (${response.statusCode}): ${response.body}"};
  }

  static Future<List<dynamic>> getTaxInvoicesByPostSales(int postSalesId) async {
    final token = TokenService.accessToken;
    final response = await http.get(
      Uri.parse("$_base/tax/postsales/$postSalesId"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    }
    return [];
  }

  static Future<bool> deleteTaxInvoice(int invoiceId) async {
    final token = TokenService.accessToken;
    final response = await http.delete(
      Uri.parse("$_base/tax/$invoiceId"),
      headers: {"Authorization": "Bearer $token"},
    );
    return response.statusCode == 200;
  }

  static Future<bool> makeInvoicePaid(String invoiceNumber, Map<String, dynamic> paymentData) async {
    final token = TokenService.accessToken;
    final url = Uri.parse("$_base/makeinvoicepaid").replace(
      queryParameters: {"invoiceNumber": invoiceNumber},
    );

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(paymentData),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
