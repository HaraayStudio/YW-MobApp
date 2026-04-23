import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  // SET THIS TO true FOR PRODUCTION
  static bool isProduction = true;

  // Real Live API
  static const String prodBaseUrl = "https://api.ywarchitects.com/api";

  // Local Development API (Change to your PC's IP if needed)
  static const String devBaseUrl = "http://10.0.2.2:8080/api";

  // Runtime override (saved in SharedPreferences)
  static String? hostOverride;

  // This is used everywhere in the app
  static String get baseUrl {
    if (hostOverride != null && hostOverride!.isNotEmpty) {
      return hostOverride!;
    }
    return isProduction ? prodBaseUrl : devBaseUrl;
  }

  // Helper for things that need the raw server without /api
  static String get serverUrl => baseUrl.replaceAll('/api', '');

  /// Loads settings from SharedPreferences
  static Future<void> loadFromSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      hostOverride = prefs.getString('custom_api_host');

      // Load saved mode (defaults to false for local dev now)
      isProduction = prefs.getBool('is_production_mode') ?? true;

      print(
        "[ApiConstants] Loaded settings: $hostOverride (Prod Mode: $isProduction)",
      );
    } catch (e) {
      print("[ApiConstants] Error loading settings: $e");
    }
  }

  /// Saves custom host to SharedPreferences
  static Future<void> saveSettings(String? newHost, bool prodMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      hostOverride = newHost;
      isProduction = prodMode;

      if (newHost == null || newHost.isEmpty) {
        await prefs.remove('custom_api_host');
      } else {
        await prefs.setString('custom_api_host', newHost);
      }
      await prefs.setBool('is_production_mode', prodMode);
    } catch (e) {
      print("[ApiConstants] Error saving settings: $e");
    }
  }
}
