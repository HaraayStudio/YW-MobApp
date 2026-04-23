import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import '../api/constants.dart';
import '../models/app_models.dart';
import 'token_service.dart';

/// Handles all authentication API calls to the Spring Boot backend.
///
/// Backend endpoints use @RequestParam (not JSON body), so
/// credentials are sent as URL query parameters.
class AuthService {
  // ─── Build Uri with @RequestParam query params ─────────────────────────────
  static Uri _buildUri(String path, Map<String, String> params) {
    final baseUri = Uri.parse(ApiConstants.baseUrl);
    // Combine base path (e.g. /api) with the endpoint path (e.g. /auth/login)
    return baseUri.replace(
      path: baseUri.path + path,
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
      case 'CLIENT':
        return UserRole.client;
      default:
        assert(() {
          // ignore: avoid_print
          print(
            '[AuthService] Unrecognised role: "$roleStr" — defaulting to employee',
          );
          return true;
        }());
        return UserRole.draftsman;
    }
  }

  // ─── Build AppUser from decoded JWT ───────────────────────────────────────
  static AppUser _buildEmployeeUser(String accessToken, String fallbackEmail) {
    final payload = _decodeJwt(accessToken);
    final roleStr = payload['role'] as String?;
    final roleEnum = _parseRole(roleStr);
    final baseInfo = roleMap[roleEnum] ?? roleMap[UserRole.admin]!;

    final id = payload['id'] as int? ?? 0;
    final fName = payload['firstName'] as String? ?? '';
    final lName = payload['lastName'] as String? ?? '';
    final email = (payload['sub'] as String?) ?? fallbackEmail;
    final phone =
        payload['phone']?.toString() ?? payload['mobile']?.toString() ?? '';

    final joinDate = payload['joinDate']?.toString() ?? '';

    return AppUser(
      id: id,
      role: roleEnum,
      token: accessToken,
      info: UserRoleInfo(
        name: '$fName $lName'.trim(),
        firstName: fName,
        lastName: lName,
        initials:
            (fName.isNotEmpty ? fName[0] : '') +
            (lName.isNotEmpty ? lName[0] : ''),
        email: email,
        label: baseInfo.label,
        nav: baseInfo.nav,
        profileImage: payload['profileImage'] as String?,
        phone: phone,
        joinDate: joinDate,
      ),
    );
  }

  // ─── Employee Login → POST /api/auth/login ────────────────────────────────
  // Spring Boot: @RequestParam("email") + @RequestParam("password")
  // → Credentials go as query params in the URL, NOT in the request body.
  //
  // Final URL example:
  //   http://localhost:8080/api/auth/login?email=admin%40yw.com&password=admin123

  // ─── Post with Timeout & Retry ─────────────────────────────────────────────
  static Future<http.Response> _postWithRetry(Uri uri) async {
    int attempts = 0;
    while (attempts < 2) {
      try {
        return await http
            .post(uri)
            .timeout(const Duration(seconds: 20));
      } catch (e) {
        print(' [AuthService] Connection error: $e');
        if (e is TimeoutException) {
          throw Exception('Connection timed out. Please check if the server is running or if your internet is stable.');
        }
        attempts++;
        if (attempts >= 2) rethrow; // Final failure
        // Fast retry: stay responsive
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    throw Exception('Unknown connection error');
  }

  static Future<AppUser> loginEmployee(String email, String password) async {
    try {
      final uri = _buildUri('/auth/login', {
        'email': email,
        'password': password,
      });

      final response = await _postWithRetry(uri);
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
          if (backendMsg.toLowerCase().contains('bad credentials') ||
              backendMsg.toLowerCase().contains('password')) {
            msg = 'Wrong password';
          } else if (backendMsg.toLowerCase().contains('null') ||
              backendMsg.toLowerCase().contains('not found') ||
              backendMsg.toLowerCase().contains('went wrong')) {
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
        'Cannot reach the server. Please check your internet connection or if the server is offline.',
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
      final uri = _buildUri('/auth/clientlogin', {
        'email': email,
        'password': password,
      });

      final response = await _postWithRetry(uri);

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

        // Try to find the ID in the response body first, then fallback to JWT, then default to 0
        final id =
            data['id'] as int? ??
            data['clientId'] as int? ??
            payload['id'] as int? ??
            0;

        final fullName =
            payload['name']?.toString() ??
            payload['fullName']?.toString() ??
            '';
        String fName = payload['firstName'] as String? ?? '';
        String lName = payload['lastName'] as String? ?? '';

        if (fullName.isNotEmpty && fName.isEmpty) {
          final parts = fullName.split(' ');
          fName = parts.first;
          lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        } else if (fName.isEmpty) {
          fName = 'Client';
        }

        return AppUser(
          id: id,
          role: UserRole.client,
          token: accessToken,
          info: UserRoleInfo(
            name: '$fName $lName'.trim(),
            firstName: fName,
            lastName: lName,
            initials:
                (fName.isNotEmpty ? fName[0] : 'C') +
                (lName.isNotEmpty ? lName[0] : 'L'),
            email: tokenEmail,
            label: 'CLIENT',
            nav: clientSidebarNav,
            profileImage: payload['profileImage'] as String?,
            phone:
                payload['phone']?.toString() ??
                payload['mobile']?.toString() ??
                '',
            address:
                payload['address']?.toString() ??
                payload['address']?.toString() ??
                '',
            gstCertificate: payload['gstcertificate']?.toString() ?? '',
            pan: payload['pan']?.toString() ?? '',
          ),
        );
      } else {
        String msg = 'Login failed (${response.statusCode})';
        try {
          final errorData = json.decode(response.body);
          final backendMsg = errorData['message']?.toString() ?? '';
          if (backendMsg.toLowerCase().contains('bad credentials') ||
              backendMsg.toLowerCase().contains('password')) {
            msg = 'Wrong password';
          } else if (backendMsg.toLowerCase().contains('null') ||
              backendMsg.toLowerCase().contains('not found') ||
              backendMsg.toLowerCase().contains('went wrong')) {
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
        'Cannot reach the server. Please check your internet connection or if the server is offline.',
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

      final id = payload['id'] as int? ?? 0;

      if (roleStr.trim().toUpperCase() == 'CLIENT') {
        final fullName =
            payload['name']?.toString() ??
            payload['fullName']?.toString() ??
            '';
        String fName = payload['firstName'] as String? ?? '';
        String lName = payload['lastName'] as String? ?? '';

        if (fullName.isNotEmpty && fName.isEmpty) {
          final parts = fullName.split(' ');
          fName = parts.first;
          lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        } else if (fName.isEmpty) {
          fName = 'Client';
        }

        return AppUser(
          id: id,
          role: UserRole.client,
          token: token,
          info: UserRoleInfo(
            name: '$fName $lName'.trim(),
            firstName: fName,
            lastName: lName,
            initials:
                (fName.isNotEmpty ? fName[0] : 'C') +
                (lName.isNotEmpty ? lName[0] : 'L'),
            email: emailStr,
            label: 'CLIENT',
            nav: clientSidebarNav,
            profileImage: payload['profileImage'] as String?,
            phone:
                payload['phone']?.toString() ??
                payload['mobile']?.toString() ??
                '',
            address: payload['address']?.toString() ?? '',
            gstCertificate: payload['gstcertificate']?.toString() ?? '',
            pan: payload['pan']?.toString() ?? '',
          ),
        );
      } else {
        return _buildEmployeeUser(token, emailStr);
      }
    } catch (_) {
      return null;
    }
  }

  // ─── Refresh Token ────────────────────────────────────────────────────────
  static Completer<bool>? _refreshCompleter;

  /// Calls the backend to get a new Access Token using the saved Refresh Token.
  /// Uses a synchronization lock to handle multiple concurrent refresh requests.
  static Future<bool> refreshAccessToken() async {
    // If a refresh is already in progress, wait for it
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = TokenService.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        print("[AuthService] No refresh token available.");
        _refreshCompleter!.complete(false);
        return false;
      }

      final uri = _buildUri('/auth/refresh', {});
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String? ?? '';
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken.isNotEmpty) {
          await TokenService.saveTokens(
            newAccessToken, 
            newRefreshToken ?? refreshToken
          );
          _refreshCompleter!.complete(true);
          return true;
        }
      }
      
      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      print("[AuthService] Token refresh error: $e");
      _refreshCompleter?.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  static void logout() {
    TokenService.clearTokens();
  }
}
