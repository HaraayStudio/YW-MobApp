import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'token_service.dart';

/// A utility class to handle API requests with automatic silent token refresh.
/// 
/// This class intercepts 401 Unauthorized errors, attempts to refresh the 
/// access token using the refresh token, and retries the original request.
class ApiHelper {
  
  /// Executes an HTTP request and automatically handles 401 Unauthorized by 
  /// attempting a token refresh and retrying the request once.
  static Future<http.Response> requestWithRetry(
    Future<http.Response> Function(String currentToken) requestFn,
  ) async {
    // 1. Initial attempt
    String? token = TokenService.accessToken ?? '';
    http.Response response = await requestFn(token);

    // 2. If unauthorized, attempt refresh
    if (response.statusCode == 401) {
      print("[ApiHelper] Unauthorized (401). Attempting silent refresh...");
      
      final success = await AuthService.refreshAccessToken();
      
      if (success) {
        print("[ApiHelper] Refresh successful. Retrying original request with new token.");
        // 3. Retry once with the new access token
        final newToken = TokenService.accessToken ?? '';
        return await requestFn(newToken);
      } else {
        print("[ApiHelper] Refresh failed or no refresh token. Propagating 401.");
        // We could trigger a logout broadcast here if needed
      }
    }

    return response;
  }

  /// Helper for GET requests with retry logic and redirect resilience
  static Future<http.Response> getWithAuth(Uri url, {Map<String, String>? headers}) async {
    return requestWithRetry((token) async {
      final combinedHeaders = {
        'Authorization': 'Bearer $token',
        ...?headers,
      };
      
      // Using a custom request to allow disabling redirects (matching existing resilient helpers)
      final client = http.Client();
      try {
        final request = http.Request('GET', url)
          ..headers.addAll(combinedHeaders)
          ..followRedirects = false;
        final streamedResponse = await client.send(request).timeout(const Duration(seconds: 45));
        return await http.Response.fromStream(streamedResponse);
      } finally {
        client.close();
      }
    });
  }

  /// Helper for POST requests with retry logic
  static Future<http.Response> postWithAuth(Uri url, {Map<String, String>? headers, Object? body}) async {
    return requestWithRetry((token) async {
      final combinedHeaders = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...?headers,
      };

      final client = http.Client();
      try {
        final request = http.Request('POST', url)
          ..headers.addAll(combinedHeaders)
          ..followRedirects = false;
        
        if (body != null) {
          if (body is String) {
            request.body = body;
          } else {
            request.body = json.encode(body);
          }
        }

        final streamedResponse = await client.send(request).timeout(const Duration(seconds: 45));
        return await http.Response.fromStream(streamedResponse);
      } finally {
        client.close();
      }
    });
  }

  /// Helper for multipart (file upload) requests with retry logic
  static Future<http.StreamedResponse> multipartRequestWithRetry(
    String method,
    Uri url,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final requestFn = (String token) async {
      final request = http.MultipartRequest(method, url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(fields);
      request.files.addAll(files);
      return await request.send();
    };

    // 1. Initial attempt
    String? token = TokenService.accessToken ?? '';
    var streamedResponse = await requestFn(token);

    // 2. If unauthorized, attempt refresh
    if (streamedResponse.statusCode == 401) {
      final success = await AuthService.refreshAccessToken();
      if (success) {
        final newToken = TokenService.accessToken ?? '';
        return await requestFn(newToken);
      }
    }

    return streamedResponse;
  }

  /// Helper for PUT requests with retry logic
  static Future<http.Response> putWithAuth(Uri url, {Map<String, String>? headers, Object? body}) async {
    return requestWithRetry((token) async {
      final combinedHeaders = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...?headers,
      };

      final client = http.Client();
      try {
        final request = http.Request('PUT', url)
          ..headers.addAll(combinedHeaders)
          ..followRedirects = false;
        
        if (body != null) {
          if (body is String) {
            request.body = body;
          } else {
            request.body = json.encode(body);
          }
        }

        final streamedResponse = await client.send(request).timeout(const Duration(seconds: 45));
        return await http.Response.fromStream(streamedResponse);
      } finally {
        client.close();
      }
    });
  }

  /// Helper for DELETE requests with retry logic
  static Future<http.Response> deleteWithAuth(Uri url, {Map<String, String>? headers}) async {
    return requestWithRetry((token) async {
      final combinedHeaders = {
        'Authorization': 'Bearer $token',
        ...?headers,
      };
      
      return await http.delete(url, headers: combinedHeaders);
    });
  }
}
