import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final bool isPrivacy;

  const LegalScreen({
    super.key,
    required this.title,
    required this.isPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19 * fontScale),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20 * fontScale),
        child: Container(
          padding: EdgeInsets.all(20 * fontScale),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22 * fontScale,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 8 * fontScale),
              Text(
                'Last Updated: September 2026',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const Divider(height: 24),
              Text(
                isPrivacy
                    ? (app.isBengali
                        ? '''
১. তথ্যের গোপনীয়তা:
রেন্টেজ্জি আপনার এবং আপনার ভাড়াটিয়াদের ব্যক্তিগত তথ্যের সর্বোচ্চ সুরক্ষা নিশ্চিত করে।

২. তথ্যের ব্যবহার:
আপনার প্রদত্ত তথ্য শুধুমাত্র ভাড়ার রসিদ প্রস্তুতকরণ, হিসাব সংরক্ষণ এবং হোয়াটসঅ্যাপে প্রেরণের সুবিধার জন্য ব্যবহৃত হয়।

৩. তথ্য বিনিময়:
আমরা তৃতীয় কোনো পক্ষের নিকট আপনার তথ্য বিক্রয় বা হস্তান্তর করি না।

৪. নিরাপত্তা:
আপনার পাসওয়ার্ড এনক্রিপ্টেড অবস্থায় সংরক্ষিত থাকে এবং অননুমোদিত প্রবেশাধিকার প্রতিরোধে আধুনিক নিরাপত্তা প্রযুক্তি প্রয়োগ করা হয়।
'''
                        : '''
1. Information Privacy:
Rentezzi ensures the highest level of security for the personal details of you and your tenants.

2. Usage of Data:
The information provided is solely utilized for generating rent receipts, managing property records, and facilitating direct WhatsApp sharing.

3. Data Sharing:
We never sell, rent, or trade your personal data to third parties.

4. Security:
Passwords are encrypted using industry-standard hashing, and all communications are securely transmitted over HTTPS.
''')
                    : (app.isBengali
                        ? '''
১. শর্তাবলীর স্বীকৃতি:
রেন্টেজ্জি ব্যবহার করার মাধ্যমে আপনি আমাদের সকল নিয়ম ও শর্তাবলী মেনে নিচ্ছেন।

২. হিসাবের সঠিকতা:
ভাড়ার পরিমাণ ও বিলের তথ্য সঠিকভাবে ইনপুট করার দায়িত্ব ব্যবহারকারীর।

৩. গ্রহণযোগ্য ব্যবহার:
অ্যাপ্লিকেশনটি শুধুমাত্র বৈধ ভাড়ার হিসাব সংরক্ষণ এবং রসিদ তৈরির কাজে ব্যবহার করা আবশ্যক।

৪. সেবার মান:
আমরা সার্বক্ষণিক নিরবচ্ছিন্ন সেবা প্রদানে প্রতিশ্রুতিবদ্ধ।
'''
                        : '''
1. Acceptance of Terms:
By accessing and using Rentezzi, you agree to comply with all platform rules and operational guidelines.

2. Accuracy of Records:
The user is responsible for ensuring the accuracy of rent amounts, tenant contacts, and utility bills entered.

3. Permitted Use:
The application is intended exclusively for lawful rent accounting and receipt generation.

4. Service Continuity:
We strive to maintain continuous availability and data integrity for all our users.
'''),
                style: TextStyle(
                  fontSize: 15.5 * fontScale,
                  height: 1.6,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
