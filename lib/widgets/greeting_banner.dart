import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';

class GreetingBanner extends StatelessWidget {
  const GreetingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final authProv = context.watch<AuthProvider>();
    final isBn = appProv.isBn;
    final isDark = appProv.isDarkMode;

    final now = DateTime.now();
    final hour = now.hour;

    String greetingKey;
    IconData timeIcon;
    Color iconColor;
    List<Color> gradientColors;

    if (hour >= 5 && hour < 12) {
      greetingKey = 'goodMorning';
      timeIcon = Icons.wb_sunny_rounded;
      iconColor = const Color(0xFFF59E0B);
      gradientColors = isDark
          ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
          : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)];
    } else if (hour >= 12 && hour < 17) {
      greetingKey = 'goodAfternoon';
      timeIcon = Icons.wb_sunny_outlined;
      iconColor = const Color(0xFFEA580C);
      gradientColors = isDark
          ? [const Color(0xFF1E1B4B), const Color(0xFF2E1065)]
          : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)];
    } else if (hour >= 17 && hour < 21) {
      greetingKey = 'goodEvening';
      timeIcon = Icons.wb_twilight_rounded;
      iconColor = const Color(0xFF8B5CF6);
      gradientColors = isDark
          ? [const Color(0xFF18181B), const Color(0xFF27272A)]
          : [const Color(0xFFF3E8FF), const Color(0xFFEDE9FE)];
    } else {
      greetingKey = 'goodNight';
      timeIcon = Icons.nightlight_round;
      iconColor = const Color(0xFF60A5FA);
      gradientColors = isDark
          ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
          : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)];
    }

    final landlordName = authProv.user?.name ?? (isBn ? 'বাড়িওয়ালা' : 'Landlord');
    final formattedDate = isBn
        ? DateFormat('EEEE, d MMMM yyyy').format(now)
        : DateFormat('EEEE, MMMM d, yyyy').format(now);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        HapticService.selection();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                timeIcon,
                color: iconColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        appProv.tr(greetingKey),
                        style: TextStyle(
                          fontSize: 14 * appProv.fontScale,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '👋',
                        style: TextStyle(fontSize: 14 * appProv.fontScale),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    landlordName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20 * appProv.fontScale,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
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
      ),
    );
  }
}
