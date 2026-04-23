import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactHelper {
  /// Opens the phone dialer with the given number
  static Future<void> makeCall(String phone) async {
    if (phone.isEmpty || phone == 'N/A') return;
    final Uri url = Uri.parse('tel:$phone');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[ContactHelper] Could not launch dialer: $e');
    }
  }

  /// Opens the default email app with the given email
  static Future<void> sendEmail(String email) async {
    if (email.isEmpty || email == 'N/A') return;
    final Uri url = Uri.parse('mailto:$email');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[ContactHelper] Could not launch email: $e');
    }
  }

  /// Copies text to clipboard
  static void copyToClipboard(String text, Function(String) onToast) {
    if (text.isEmpty || text == 'N/A') return;
    Clipboard.setData(ClipboardData(text: text));
    onToast('Copied to clipboard');
  }
}
