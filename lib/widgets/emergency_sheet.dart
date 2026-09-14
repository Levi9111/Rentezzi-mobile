import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../providers/app_provider.dart';

class EmergencyHelplineSheet extends StatelessWidget {
  const EmergencyHelplineSheet({super.key});

  static void show(BuildContext context) {
    HapticService.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const EmergencyHelplineSheet(),
    );
  }

  Future<void> _callHotline(String number) async {
    HapticService.heavy();
    final uri = Uri.parse('tel:$number');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final isBn = appProv.isBn;
    final isDark = appProv.isDarkMode;

    final helplines = [
      {
        'nameEn': 'National Emergency (Police, Fire, Ambulance)',
        'nameBn': 'জাতীয় জরুরি সেবা (পুলিশ, ফায়ার, অ্যাম্বুলেন্স)',
        'number': '999',
        'icon': '🚨',
        'color': const Color(0xFFDC2626),
      },
      {
        'nameEn': 'WASA Water Supply Helpline',
        'nameBn': 'ঢাকা ওয়াসা পানি সমস্যা হটলাইন',
        'number': '16162',
        'icon': '💧',
        'color': const Color(0xFF0284C7),
      },
      {
        'nameEn': 'Titas Gas Leakage Hotline',
        'nameBn': 'তিতাস গ্যাস লিকেজ ও জরুরি সেবা',
        'number': '16496',
        'icon': '🔥',
        'color': const Color(0xFFD97706),
      },
      {
        'nameEn': 'DESCO Electricity Emergency',
        'nameBn': 'ডেসকো বিদ্যুৎ সমস্যা হেল্পলাইন',
        'number': '16120',
        'icon': '⚡',
        'color': const Color(0xFFEAB308),
      },
      {
        'nameEn': 'DPDC Electricity Helpline',
        'nameBn': 'ডিপিডিসি বিদ্যুৎ হেল্পলাইন',
        'number': '16116',
        'icon': '💡',
        'color': const Color(0xFF10B981),
      },
      {
        'nameEn': 'Fire Service Emergency',
        'nameBn': 'ফায়ার সার্ভিস অ্যান্ড সিভিল ডিফেন্স',
        'number': '102',
        'icon': '🚒',
        'color': const Color(0xFFEF4444),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('🚨', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appProv.tr('emergencyHelplines'),
                      style: TextStyle(
                        fontSize: 18 * appProv.fontScale,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      appProv.tr('emergencyHelplinesSubtitle'),
                      style: TextStyle(
                        fontSize: 12 * appProv.fontScale,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...helplines.map((item) {
            final name = isBn ? item['nameBn'] as String : item['nameEn'] as String;
            final number = item['number'] as String;
            final icon = item['icon'] as String;
            final color = item['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _callHotline(number),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 13 * appProv.fontScale,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Hotline: $number',
                              style: TextStyle(
                                fontSize: 13 * appProv.fontScale,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              number,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14 * appProv.fontScale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
