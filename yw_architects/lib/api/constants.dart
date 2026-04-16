import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static const String _host = '192.168.31.212';
  static const int _port = 8080;

  static String get host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return _host;
  }

  static String get baseUrl => "http://$host:$_port/api";
  static String get serverUrl => "http://$host:$_port";
}
