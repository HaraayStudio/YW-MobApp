
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  // SET THIS TO true FOR RELEASE / PRODUCTION APK
  static bool isProduction = true;

  // YOUR PRODUCTION DOMAIN (e.g., 'api.ywarchitects.com')
  static const String prodHost = 'api.ywarchitects.com';

  // LOCAL DEVELOPMENT IP (Only works on your local WiFi)
  static const String devHost = '192.168.1.5';

  static const int port = 8080;

  // Runtime override (saved in SharedPreferences)
  static String? hostOverride;

  static String get host {
    if (kIsWeb) return 'localhost';

    // 1. User specified override (via settings)
    if (hostOverride != null && hostOverride!.isNotEmpty) {
      return hostOverride!;
    }

    // 2. Production domain
    if (isProduction) return prodHost;

    // 3. Local Development
    return devHost;
  }

  static String get scheme => isProduction ? 'https' : 'http';

  static String get baseUrl {
    if (host.startsWith('http')) return "$host/api";
    if (isProduction) return "https://$host/api";
    return "http://$host:$port/api";
  }

  static String get serverUrl {
    if (host.startsWith('http')) return host;
    if (isProduction) return "https://$host";
    return "http://$host:$port";
  }

  /// Loads custom host from SharedPreferences
  static Future<void> loadFromSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      hostOverride = prefs.getString('custom_api_host');
      isProduction = prefs.getBool('is_production_mode') ?? true;
      print(
        "[ApiConstants] Loaded host override: $hostOverride (Prod: $isProduction)",
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
