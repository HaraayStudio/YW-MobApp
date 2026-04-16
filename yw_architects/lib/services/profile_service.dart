import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../api/constants.dart';
import '../models/app_models.dart';
import 'token_service.dart';
import 'client_service.dart';

/// Dedicated service for all Profile-related API calls.
/// Mirrors the web app's employee.api.js pattern but scoped only to
/// the "my profile" operations (not admin-level employee management).
class ProfileService {
  static String get _baseUrl => "${ApiConstants.baseUrl}/employees";

  // ── Auth Headers ────────────────────────────────────────────────────────────
  static Map<String, String> get _authHeaders => {
        "Authorization": "Bearer ${TokenService.accessToken}",
      };

  static Map<String, String> get _jsonHeaders => {
        "Authorization": "Bearer ${TokenService.accessToken}",
        "Content-Type": "application/json",
      };

  // ── Resilient HTTP Helpers ───────────────────────────────────────────────────
  // These helpers disable automatic redirect-following to prevent crashes on
  // certain backend 3xx responses that don't include a Location header.

  static Future<http.Response> _resilientGet(Uri url) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', url)
        ..headers.addAll(_authHeaders)
        ..followRedirects = false;
      
      // Send and await response within a single timeout context
      final streamed = await client.send(request).timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed).timeout(const Duration(seconds: 10));
      return response;
    } finally {
      client.close();
    }
  }

  static Future<http.Response> _resilientPut(Uri url, dynamic body) async {
    final client = http.Client();
    try {
      final request = http.Request('PUT', url)
        ..headers.addAll(_jsonHeaders)
        ..followRedirects = false;
      if (body != null) {
        request.body = body is String ? body : jsonEncode(body);
      }
      final streamed = await client.send(request).timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed).timeout(const Duration(seconds: 10));
      return response;
    } finally {
      client.close();
    }
  }

  // ── API Methods ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getMyProfile({UserRole? role, int? id, String? email}) async {
    try {
      Uri url;
      int? effectiveId = id;

      if (role == UserRole.client) {
        // Robust Fallback: If ID is missing, try resolving by email
        if ((effectiveId == null || effectiveId == 0) && email != null) {
          debugPrint("PROFILE SERVICE — ID is 0, attempting email resolution for $email...");
          effectiveId = await ClientService.resolveClientIdByEmail(email);
        }
        
        if (effectiveId == null || effectiveId == 0) {
          debugPrint("PROFILE SERVICE — FAILED to resolve client ID.");
          return null;
        }
        
        url = Uri.parse("${ApiConstants.baseUrl}/clients/getclientbyid/$effectiveId");
      } else {
        url = Uri.parse("$_baseUrl/getemployeedata");
      }

      final response = await _resilientGet(url);
      debugPrint("PROFILE SERVICE — GET STATUS: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 302 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        
        // Handle instances where data is un-wrapped and prevent List crashes
        dynamic rawData;
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          rawData = decoded['data'];
        } else {
          rawData = decoded;
        }
        
        // Use the resilient extractor to flatten the structure
        final data = extractUserData(rawData);
        
        debugPrint("PROFILE SERVICE — KEYS RECEIVED: ${data?.keys.toList()}");
        return data;
      }
    } catch (e) {
      debugPrint("PROFILE SERVICE — GET ERROR: $e");
    }
    return null;
  }

  /// GET /api/employees/getmyprojects
  /// Returns the list of projects assigned to the current employee.
  /// Used to calculate the real-time project count shown on the profile.
  static Future<List<dynamic>> getMyProjects({int page = 0, int size = 100}) async {
    try {
      final response = await _resilientGet(
        Uri.parse("$_baseUrl/getmyprojects?page=$page&size=$size"),
      );
      debugPrint("PROFILE SERVICE — PROJECTS STATUS: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 302 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? [];
      }
    } catch (e) {
      debugPrint("PROFILE SERVICE — PROJECTS ERROR: $e");
    }
    return [];
  }

  /// PUT /api/employees/updatemyprofile
  /// Updates the editable fields of the current employee's profile.
  /// The payload should include both snake_case and camelCase keys for compatibility.
  static Future<bool> updateMyProfile(Map<String, dynamic> payload) async {
    try {
      final response = await _resilientPut(
        Uri.parse("$_baseUrl/updatemyprofile"),
        payload,
      );
      debugPrint("PROFILE SERVICE — UPDATE STATUS: ${response.statusCode}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("PROFILE SERVICE — UPDATE ERROR BODY: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("PROFILE SERVICE — UPDATE ERROR: $e");
      return false;
    }
  }

  /// PUT /api/employees/updatemypassword
  /// Changes the password of the currently authenticated user.
  static Future<bool> updateMyPassword(String oldPassword, String newPassword) async {
    try {
      final response = await _resilientPut(
        Uri.parse("$_baseUrl/updatemypassword?oldPassword=$oldPassword&newPassword=$newPassword"),
        null,
      );
      debugPrint("PROFILE SERVICE — PASSWORD STATUS: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("PROFILE SERVICE — PASSWORD ERROR: $e");
      return false;
    }
  }

  /// PUT /api/employees/updatemyprofileimage (multipart/form-data)
  /// Uploads a new profile image for the current employee.
  static Future<bool> updateMyProfileImage(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse("$_baseUrl/updatemyprofileimage"),
      );
      request.headers['Authorization'] = "Bearer ${TokenService.accessToken}";
      
      // Determine content type to prevent backend IllegalArgumentException rejections
      final ext = filePath.split('.').last.toLowerCase();
      MediaType mediaType = MediaType('image', 'jpeg'); // default fallback
      if (ext == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (ext == 'webp') {
        mediaType = MediaType('image', 'webp');
      }

      request.files.add(await http.MultipartFile.fromPath(
        'profileimage', 
        filePath,
        contentType: mediaType,
      ));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      debugPrint("PROFILE SERVICE — IMAGE STATUS: ${response.statusCode}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("PROFILE SERVICE — IMAGE ERROR BODY: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("PROFILE SERVICE — IMAGE ERROR: $e");
      return false;
    }
  }

  // ── Data Helpers ────────────────────────────────────────────────────────────

  /// Resiliently flattens common Spring Boot / Spring Data REST patterns.
  /// Handles:
  /// 1. Direct Map: { "firstName": "..." }
  /// 2. Nested User: { "user": { "firstName": "..." } }
  /// 3. Nested Employee: { "employee": { "firstName": "..." } }
  /// 4. List: [ { "firstName": "..." } ]
  static Map<String, dynamic>? extractUserData(dynamic raw) {
    if (raw == null) return null;

    Map<String, dynamic>? target;

    if (raw is List) {
      if (raw.isEmpty) return null;
      target = raw[0] as Map<String, dynamic>?;
    } else if (raw is Map<String, dynamic>) {
      target = raw;
    }

    if (target == null) return null;

    // Flatten the structure: merge nested objects, but ignore nulls
    // so we don't accidentally overwrite a valid name with a null property.
    final combined = <String, dynamic>{};

    // 1. Add everything from root, omitting nulls
    target.forEach((key, value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        combined[key] = value;
      }
    });

    // 2. Add nested 'employee', omitting nulls
    if (target['employee'] is Map<String, dynamic>) {
      (target['employee'] as Map<String, dynamic>).forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          combined[key] = value;
        }
      });
    }

    // 3. Add nested 'user', omitting nulls (User details take highest precedence)
    if (target['user'] is Map<String, dynamic>) {
      (target['user'] as Map<String, dynamic>).forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          combined[key] = value;
        }
      });
    }

    // 4. Handle Client specific keys from separate table
    // (Database has: id, gstcertificate, pan, address, email, name, phone, role)
    final clientKeys = ['gstcertificate', 'pan', 'address'];
    for (var key in clientKeys) {
      if (target.containsKey(key) && target[key] != null) {
        combined[key] = target[key];
      }
    }

    // Fallback specific fields
    if (!combined.containsKey('name') || combined['name'] == '') {
       final first = combined['firstName']?.toString() ?? combined['first_name']?.toString() ?? '';
       final last = combined['lastName']?.toString() ?? combined['last_name']?.toString() ?? '';
       final full = '$first $last'.trim();
       if (full.isNotEmpty) {
         combined['name'] = full;
       }
    }

    return combined;
  }

  /// Returns the full name by checking both snake_case and camelCase keys.
  static String extractFullName(Map<String, dynamic>? data) {
    if (data == null) return '';
    
    // Check if there is already a flattened or explicitly provided full 'name'
    if (data['name'] != null && data['name'].toString().trim().isNotEmpty) {
      return data['name'].toString().trim();
    }
    
    final first = data['firstName']?.toString() ?? data['first_name']?.toString() ?? '';
    final last = data['lastName']?.toString() ?? data['last_name']?.toString() ?? '';
    return '$first $last'.trim();
  }

  /// Returns a formatted Employee ID like "YW-007" from the numeric DB id.
  static String formatEmployeeId(dynamic id) {
    if (id == null) return 'YW-000';
    return 'YW-${id.toString().padLeft(3, '0')}';
  }

  /// Formats a "YYYY-MM-DD" date string to "2 Apr 2026" style display text.
  static String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '—';
    try {
      final dt = DateTime.parse(rawDate);
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (_) {
      return rawDate;
    }
  }
}
