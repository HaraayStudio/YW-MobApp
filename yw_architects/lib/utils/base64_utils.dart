import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class Base64Utils {
  /// Converts an XFile to a Base64 string with the data scheme prefix.
  /// Example: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...
  static Future<String?> toDataUrl(XFile? file) async {
    if (file == null) return null;

    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Get extension
      final extension = file.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(extension);
      
      return "data:$mimeType;base64,$base64String";
    } catch (e) {
      print("Error converting image to Base64: $e");
      return null;
    }
  }

  static String _getMimeType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/png';
    }
  }

  /// Checks if a string is a Base64 data URL.
  static bool isBase64(String? value) {
    if (value == null) return false;
    return value.startsWith('data:image');
  }
}
