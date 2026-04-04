import 'dart:convert';
import 'dart:io' show Platform, SocketException;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/app_models.dart';
import 'token_service.dart';

/// Handles all authentication API calls to the Spring Boot backend.
///
/// Backend endpoints use @RequestParam (not JSON body), so
/// credentials are sent as URL query parameters.
class AuthService {
  // ─── Host / Port ──────────────────────────────────────────────────────────
  static const String _host = 'localhost';
  static const int _port = 8080;

  // On Android emulator "localhost" routes to the emulator itself, not the PC.
  // 10.0.2.2 is the standard alias that reaches the host machine.
  static String get _resolvedHost {
    if (kIsWeb) return _host; // Web: CORS+fetch, localhost is fine
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return _host; // desktop / iOS / macOS
  }

  // ─── Build Uri with @RequestParam query params ─────────────────────────────
  // Using Uri.http() causes Dart to percent-encode special chars automatically,
  // so passwords containing @, +, #, & etc. never break the URL.
  static Uri _buildUri(String path, Map<String, String> params) {
    return Uri(
      scheme: 'http',
      host: _resolvedHost,
      port: _port,
      path: path,
      queryParameters: params,
    );
  }

  // ─── JWT Decoder ──────────────────────────────────────────────────────────
  static Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ─── Role Parser ──────────────────────────────────────────────────────────
  // Maps DB role strings (embedded in JWT by JwtUtil.generateAccessToken)
  // to local Flutter UserRole enum values.
  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.trim().toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'CO_FOUNDER':
        return UserRole.coFounder;
      case 'HR':
        return UserRole.hr;
      case 'SR_ARCHITECT':
        return UserRole.srArchitect;
      case 'JR_ARCHITECT':
        return UserRole.jrArchitect;
      case 'SR_ENGINEER':
        return UserRole.srEngineer;
      case 'DRAFTSMAN':
        return UserRole.draftsman;
      case 'LIAISON_MANAGER':
        return UserRole.liaisonManager;
      case 'LIAISON_OFFICER':
        return UserRole.liaisonOfficer;
      case 'LIAISON_ASSISTANT':
        return UserRole.liaisonAssistant;
      default:
        assert(() {
          // ignore: avoid_print
          print(
            '[AuthService] Unrecognised role: "$roleStr" — defaulting to admin',
          );
          return true;
        }());
        return UserRole.admin;
    }
  }

  // ─── Build AppUser from decoded JWT ───────────────────────────────────────
  static AppUser _buildEmployeeUser(String accessToken, String fallbackEmail) {
    final payload = _decodeJwt(accessToken);
    final roleStr = payload['role'] as String?;
    final email = (payload['sub'] as String?) ?? fallbackEmail;
    final roleEnum = _parseRole(roleStr);
    final baseInfo = roleMap[roleEnum] ?? roleMap[UserRole.admin]!;

    return AppUser(
      role: roleEnum,
      token: accessToken,
      info: UserRoleInfo(
        name: baseInfo.name,
        initials: baseInfo.initials,
        email: email,
        label: baseInfo.label,
        nav: baseInfo.nav,
      ),
    );
  }

  // ─── Employee Login → POST /api/auth/login ────────────────────────────────
  // Spring Boot: @RequestParam("email") + @RequestParam("password")
  // → Credentials go as query params in the URL, NOT in the request body.
  //
  // Final URL example:
  //   http://localhost:8080/api/auth/login?email=admin%40yw.com&password=admin123

  static Future<AppUser> loginEmployee(String email, String password) async {
    print("This is trying to login");
    try {
      final uri = _buildUri('/api/auth/login', {
        'email': email,
        'password': password,
      });
      print("This is trying to login" + uri.toString());
      // Debug: print the exact URL being hit
      assert(() {
        print('[AuthService] POST $uri');
        return true;
      }());

      final response = await http
          .post(uri)
          .timeout(const Duration(seconds: 15));
      print("response" + response.body);
      assert(() {
        print(
          '[AuthService] Response ${response.statusCode}: ${response.body}',
        );
        return true;
      }());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String?;
        if (accessToken.isEmpty) {
          throw Exception('Server returned an empty token. Please try again.');
        }
        // TokenService.accessToken = accessToken;
        // TokenService.refreshToken = refreshToken;
        print("accessToken" + accessToken);
        //print("refreshToken" + refreshToken);
        await TokenService.saveTokens(accessToken, refreshToken);
        return _buildEmployeeUser(accessToken, email);
      } else {
        String msg = 'Login failed (${response.statusCode})';
        try {
          final errorData = json.decode(response.body);
          final backendMsg = errorData['message']?.toString() ?? '';
          if (backendMsg.toLowerCase().contains('bad credentials') || backendMsg.toLowerCase().contains('password')) {
            msg = 'Wrong password';
          } else if (backendMsg.toLowerCase().contains('null') || backendMsg.toLowerCase().contains('not found') || backendMsg.toLowerCase().contains('went wrong')) {
            msg = 'Wrong username';
          } else {
            msg = backendMsg;
          }
        } catch (_) {
          if (response.statusCode == 401) {
            msg = 'Wrong password';
          } else if (response.statusCode == 500 || response.statusCode == 404) {
            msg = 'Wrong username';
          }
        }
        // Remove the 'Exception: ' prefix when propagating by throwing a string or stripping it at the UI layer.
        // But since we throw Exception, we'll keep the text clean so the UI can strip 'Exception: '
        throw Exception(msg);
      }
    } on SocketException {
      throw Exception(
        'Cannot reach the server. Is the backend running on port $_port?',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  // ─── Client Login → POST /api/auth/clientlogin ────────────────────────────
  // Spring Boot: @RequestParam("email") + @RequestParam("password")
  //
  // Final URL example:
  //   http://localhost:8080/api/auth/clientlogin?email=client%40yw.com&password=client123
  static Future<AppUser> loginClient(String email, String password) async {
    try {
      final uri = _buildUri('/api/auth/clientlogin', {
        'email': email,
        'password': password,
      });

      assert(() {
        print('[AuthService] POST $uri');
        return true;
      }());

      final response = await http
          .post(uri)
          .timeout(const Duration(seconds: 15));

      assert(() {
        print(
          '[AuthService] Response ${response.statusCode}: ${response.body}',
        );
        return true;
      }());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String?;
        if (accessToken.isEmpty) {
          throw Exception('Server returned an empty token. Please try again.');
        }
        TokenService.accessToken = accessToken;
        TokenService.refreshToken = refreshToken;

        final payload = _decodeJwt(accessToken);
        final tokenEmail = (payload['sub'] as String?) ?? email;

        return AppUser(
          role: UserRole.admin, // Clients: restricted nav; no separate enum yet
          token: accessToken,
          info: const UserRoleInfo(
            name: 'Client',
            initials: 'CL',
            email: '',
            label: 'CLIENT',
            nav: ['dashboard', 'projects', 'profile'],
          ).copyWith(email: tokenEmail),
        );
      } else {
        String msg = 'Login failed (${response.statusCode})';
        try {
          final errorData = json.decode(response.body);
          final backendMsg = errorData['message']?.toString() ?? '';
          if (backendMsg.toLowerCase().contains('bad credentials') || backendMsg.toLowerCase().contains('password')) {
            msg = 'Wrong password';
          } else if (backendMsg.toLowerCase().contains('null') || backendMsg.toLowerCase().contains('not found') || backendMsg.toLowerCase().contains('went wrong')) {
            msg = 'Wrong username';
          } else {
            msg = backendMsg;
          }
        } catch (_) {
          if (response.statusCode == 401) {
            msg = 'Wrong password';
          } else if (response.statusCode == 500 || response.statusCode == 404) {
            msg = 'Wrong username';
          }
        }
        throw Exception(msg);
      }
    } on SocketException {
      throw Exception(
        'Cannot reach the server. Is the backend running on port $_port?',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  // ─── Auto Login ───────────────────────────────────────────────────────────
  static AppUser? tryAutoLogin() {
    try {
      final token = TokenService.accessToken;
      if (token == null || token.isEmpty) return null;

      final payload = _decodeJwt(token);
      final roleStr = payload['role'] as String?;
      final emailStr = payload['sub'] as String? ?? '';

      // Basic validation of payload
      if (roleStr == null) return null;

      if (roleStr.trim().toUpperCase() == 'CLIENT') {
        return AppUser(
          role: UserRole.admin,
          token: token,
          info: const UserRoleInfo(
            name: 'Client',
            initials: 'CL',
            email: '',
            label: 'CLIENT',
            nav: ['dashboard', 'projects', 'profile'],
          ).copyWith(email: emailStr),
        );
      } else {
        return _buildEmployeeUser(token, emailStr);
      }
    } catch (_) {
      return null;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  static void logout() {
    TokenService.clearTokens();
  }
}
