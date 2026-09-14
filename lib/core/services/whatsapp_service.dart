import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/receipt_model.dart';

class WhatsAppService {
  /// Normalize Bangladesh phone number for WhatsApp link
  static String formatPhoneForWhatsApp(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('01')) {
      cleaned = '88$cleaned';
    } else if (cleaned.startsWith('+8801')) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  /// Create and launch WhatsApp message for a rent receipt
  static Future<bool> shareReceiptViaWhatsApp(
    ReceiptModel receipt, {
    String? overridePhone,
    String lang = 'bn',
  }) async {
    final phoneToUse = overridePhone ?? receipt.tenantPhone ?? '';
    if (phoneToUse.trim().isEmpty) return false;

    final formattedPhone = formatPhoneForWhatsApp(phoneToUse);
    final totalFormatted = NumberFormat('#,##,###').format(receipt.totalAmount);

    String message;
    if (lang == 'bn' || receipt.receiptLang == 'bn') {
      message = '''
আসসালামু আলাইকুম ${receipt.tenantName},
আপনার ${receipt.monthYear} মাসের বাসা ভাড়ার আনুষ্ঠানিক রসিদ প্রস্তুত হয়েছে।

📋 রসিদ নং: #${receipt.id.length > 8 ? receipt.id.substring(0, 8).toUpperCase() : receipt.id.toUpperCase()}
🏢 বাড়ি/ফ্ল্যাট: ${receipt.propertyName ?? ''} (${receipt.unitName ?? ''})
💰 পরিশোধিত মোট ভাড়া: ৳$totalFormatted
📅 পরিশোধের তারিখ: ${receipt.paymentDate}
💳 পরিশোধ পদ্ধতি: ${receipt.paymentMethod.toUpperCase()}

ধন্যবাদ!
— ${receipt.landlordName ?? 'বাড়িওয়ালা'} (রেন্টেজ্জি ভাড়ার হিসাব)
''';
    } else {
      message = '''
Hello ${receipt.tenantName},
Here is your official rent receipt for ${receipt.monthYear}.

📋 Receipt ID: #${receipt.id.length > 8 ? receipt.id.substring(0, 8).toUpperCase() : receipt.id.toUpperCase()}
🏢 Property/Unit: ${receipt.propertyName ?? ''} (${receipt.unitName ?? ''})
💰 Total Amount Paid: BDT $totalFormatted
📅 Payment Date: ${receipt.paymentDate}
💳 Payment Method: ${receipt.paymentMethod.toUpperCase()}

Thank you!
— ${receipt.landlordName ?? 'Landlord'} (Rentezzi Rent Management)
''';
    }

    final encodedMessage = Uri.encodeComponent(message.trim());
    final url = Uri.parse('https://wa.me/$formattedPhone?text=$encodedMessage');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> sendReceiptViaWhatsApp({
    required ReceiptModel receipt,
    required String tenantPhone,
    required bool isBn,
  }) => shareReceiptViaWhatsApp(receipt, overridePhone: tenantPhone, lang: isBn ? 'bn' : 'en');
}
