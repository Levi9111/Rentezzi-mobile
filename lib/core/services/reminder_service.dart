import 'package:url_launcher/url_launcher.dart';

enum ReminderTone { friendly, festive, standard, urgent }

class ReminderService {
  static String generateMessage({
    required String tenantName,
    required String propertyName,
    required String unitName,
    required String month,
    required double amount,
    required ReminderTone tone,
    required bool isBn,
  }) {
    final int amountInt = amount.round();

    if (isBn) {
      switch (tone) {
        case ReminderTone.friendly:
          return 'আসসালামু আলাইকুম $tenantName ভাই/আপা, আশা করি ভালো আছেন। $propertyName-এর $unitName ফ্ল্যাটের $month মাসের বাসা ভাড়া (৳$amountInt) সুবিধাজনক সময়ে পাঠিয়ে দিলে উপকৃত হবো। ধন্যবাদ!';
        case ReminderTone.festive:
          return 'আসসালামু আলাইকুম $tenantName ভাই/আপা, আপনার ও পরিবারের সকলের কুশল কামনা করছি। $propertyName, $unitName-এর $month মাসের বাসা ভাড়া (৳$amountInt) পরিশোধের জন্য বিনীত অনুরোধ রইল। ভালো থাকবেন!';
        case ReminderTone.standard:
          return 'আসসালামু আলাইকুম $tenantName সাহেব, এটি $propertyName-এর $unitName ইউনিটের $month মাসের বাড়ি ভাড়া (৳$amountInt) সংক্রান্ত একটি বিনীত স্মরণিকা। বকেয়া ভাড়াটি পরিশোধের ব্যবস্থা নিলে কৃতজ্ঞ থাকবো। ধন্যবাদ!';
        case ReminderTone.urgent:
          return 'আসসালামু আলাইকুম $tenantName, $propertyName ($unitName)-এর $month মাসের বাসা ভাড়া (৳$amountInt) এখনও অপরিশোধিত রয়েছে। দয়া করে দ্রুত ভাড়াটি পরিশোধের বিনীত অনুরোধ জানাচ্ছি। ধন্যবাদ!';
      }
    } else {
      switch (tone) {
        case ReminderTone.friendly:
          return 'Hello $tenantName, hope you are having a wonderful day! Just a gentle reminder regarding the rent for $month ($unitName at $propertyName), total: ৳$amountInt. Whenever convenient, please arrange the payment. Thank you!';
        case ReminderTone.festive:
          return 'Warm greetings to you and your family, $tenantName! This is a courteous reminder for $month rent of $unitName, $propertyName (৳$amountInt). Wishing you the very best!';
        case ReminderTone.standard:
          return 'Dear $tenantName, this is a friendly reminder for the rent of $month for $unitName at $propertyName. The total amount is ৳$amountInt. Please clear the dues at your earliest convenience. Thank you!';
        case ReminderTone.urgent:
          return 'Dear $tenantName, this is an important follow-up regarding your pending rent for $month ($propertyName, $unitName) amounting to ৳$amountInt. Kindly arrange the payment as soon as possible. Thank you.';
      }
    }
  }

  static Future<bool> sendWhatsAppReminder({
    required String phone,
    required String message,
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '88$cleanPhone';
    } else if (!cleanPhone.startsWith('880') && cleanPhone.length == 10) {
      cleanPhone = '880$cleanPhone';
    }

    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> sendSmsReminder({
    required String phone,
    required String message,
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('sms:$cleanPhone?body=$encodedMessage');

    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
