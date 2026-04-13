// import 'package:shared_preferences/shared_preferences.dart';

// class TokenService {
//   static late SharedPreferences _prefs;

//   // Initialize SharedPreferences once
//   static Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   // Getter and Setter for Access Token
//   static String? get accessToken {
//     return _prefs.getString('access_token');
//   }

//   static set accessToken(String? value) {
//     if (value == null || value.isEmpty) {
//       _prefs.remove('access_token');
//     } else {
//       _prefs.setString('access_token', value);
//     }
//   }

//   // Getter and Setter for Refresh Token
//   static String? get refreshToken {
//     return _prefs.getString('refresh_token');
//   }

//   static set refreshToken(String? value) {
//     if (value == null || value.isEmpty) {
//       _prefs.remove('refresh_token');
//     } else {
//       _prefs.setString('refresh_token', value);
//     }
//   }

//   // Helper to clear tokens
//   static void clearTokens() {
//     accessToken = null;
//     refreshToken = null;
//   }
// }


import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static String? accessToken;
  static String? refreshToken;
  static late SharedPreferences _prefs;
 
 // 🔥 SAVE TOKENS (PERMANENT)
  static Future<void> init() async {
    try {
      print("[TokenService] Initializing SharedPreferences...");
      _prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 4));
      await _loadToMemory();
      print("[TokenService] Initialization successful.");
    } catch (e) {
      print("[TokenService] ERROR during initialization: $e");
    }
  }

  // Private helper to populate memory variables
  static Future<void> _loadToMemory() async {
    accessToken = _prefs.getString('accessToken');
    refreshToken = _prefs.getString('refreshToken');
  }

  static Future<void> saveTokens(String access, String? refresh) async {
    accessToken = access;
    refreshToken = refresh;

    await _prefs.setString('accessToken', access);
    if (refresh != null) {
      await _prefs.setString('refreshToken', refresh);
    }
  }

  // This is now redundant but kept for any external direct calls, 
  // though we prefer init() + static accessors.
  static Future<void> loadTokens() async {
    await _loadToMemory();
  }

  static Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
    await _prefs.remove('accessToken');
    await _prefs.remove('refreshToken');
  }
}