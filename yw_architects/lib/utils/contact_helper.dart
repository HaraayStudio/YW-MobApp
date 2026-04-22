import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactHelper {
  /// Opens the phone dialer with the given number
  static Future<void> makeCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Opens the default email app with the given email
  static Future<void> sendEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Copies text to clipboard
  static void copyToClipboard(String text, Function(String) onToast) {
    if (text.isEmpty || text == 'N/A') return;
    Clipboard.setData(ClipboardData(text: text));
    onToast('Copied to clipboard');
  }
}
