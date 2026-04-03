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
    // Initialize SharedPreferences once
 
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  static Future<void> saveTokens(
      String access, String? refresh) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('accessToken', access);
    if (refresh != null) {
      await prefs.setString('refreshToken', refresh);
    }

    // also keep in memory
    accessToken = access;
    refreshToken = refresh;
  }

  // 🔥 LOAD TOKENS (APP START)
  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();

    accessToken = prefs.getString('accessToken');
    refreshToken = prefs.getString('refreshToken');
  }

  // 🔥 CLEAR TOKENS (LOGOUT)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    accessToken = null;
    refreshToken = null;
  }
}