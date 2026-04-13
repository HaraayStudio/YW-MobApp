import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:yw_architects/services/auth_service.dart';
import 'package:yw_architects/services/token_service.dart';
import 'package:yw_architects/api/constants.dart';

class AttendanceService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final token = TokenService.accessToken;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// GET /attendance/today
  static Future<List<dynamic>> getTodayAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/today'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] as List<dynamic>? ?? [];
      }
    } catch (e) {
      debugPrint("Error fetching today's attendance: $e");
    }
    return [];
  }

  /// POST /attendance/bulk?date=YYYY-MM-DD
  static Future<bool> markBulkAttendance(String date, List<Map<String, dynamic>> records) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/bulk').replace(queryParameters: {'date': date}),
        body: json.encode(records),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error marking bulk attendance: $e");
      return false;
    }
  }

  /// GET /attendance/all?month=X&year=Y
  static Future<List<dynamic>> getAllEmployeesMonthlyAttendance(int month, int year) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/all').replace(queryParameters: {
          'month': month.toString(),
          'year': year.toString(),
        }),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] as List<dynamic>? ?? [];
      }
    } catch (e) {
      debugPrint("Error fetching monthly attendance: $e");
    }
    return [];
  }

  /// PATCH /attendance/{userId}/checkin?date=...&time=...
  static Future<bool> recordCheckIn(int userId, String date, String time) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/attendance/$userId/checkin').replace(queryParameters: {
          'date': date,
          'time': time,
        }),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error recording check-in: $e");
      return false;
    }
  }

  /// PATCH /attendance/{userId}/checkout?date=...&time=...&attendanceStatus=...
  static Future<bool> recordCheckOut(int userId, String date, String time, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/attendance/$userId/checkout').replace(queryParameters: {
          'date': date,
          'time': time,
          'attendanceStatus': status,
        }),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error recording check-out: $e");
      return false;
    }
  }
}
