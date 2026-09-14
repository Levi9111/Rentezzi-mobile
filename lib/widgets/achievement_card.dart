import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../models/achievement_model.dart';
import '../providers/app_provider.dart';
import '../providers/property_provider.dart';
import '../providers/receipt_provider.dart';

class AchievementBadgesSection extends StatelessWidget {
  const AchievementBadgesSection({super.key});

  List<AchievementModel> _computeAchievements({
    required int receiptCount,
    required int propertyCount,
    required int vacantCount,
    required int totalUnits,
  }) {
    return [
      AchievementModel(
        id: 'super_landlord',
        titleEn: 'Super Landlord',
        titleBn: 'সেরা বাড়িওয়ালা',
        descriptionEn: 'Create 5 or more rent receipts',
        descriptionBn: '৫টি বা তার বেশি ভাড়ার রসিদ তৈরি করুন',
        iconEmoji: '🏆',
        isUnlocked: receiptCount >= 5,
        progress: (receiptCount / 5).clamp(0.0, 1.0),
        currentProgressLabel: '$receiptCount / 5',
      ),
      AchievementModel(
        id: 'active_collector',
        titleEn: 'Prompt Collector',
        titleBn: 'নিয়মিত আদায়কারী',
        descriptionEn: 'Active receipts generated this month',
        descriptionBn: 'এই মাসে ভাড়ার হিসাব সক্রিয় রাখা',
        iconEmoji: '⚡',
        isUnlocked: receiptCount >= 1,
        progress: receiptCount >= 1 ? 1.0 : 0.0,
        currentProgressLabel: receiptCount >= 1 ? 'Active' : '0/1',
      ),
      AchievementModel(
        id: 'property_mogul',
        titleEn: 'Property Mogul',
        titleBn: 'বাড়িওয়ালা রত্ন',
        descriptionEn: 'Manage 2 or more properties',
        descriptionBn: '২ বা তার বেশি বাড়ি পরিচালনা করুন',
        iconEmoji: '🏢',
        isUnlocked: propertyCount >= 2,
        progress: (propertyCount / 2).clamp(0.0, 1.0),
        currentProgressLabel: '$propertyCount / 2',
      ),
      AchievementModel(
        id: 'full_house',
        titleEn: 'Full House',
        titleBn: 'শতভাগ পূর্ণ',
        descriptionEn: 'All units occupied (0 vacant)',
        descriptionBn: 'সবগুলো ফ্ল্যাটে ভাড়াটিয়া বর্তমান (০ খালি)',
        iconEmoji: '🎯',
        isUnlocked: totalUnits > 0 && vacantCount == 0,
        progress: totalUnits > 0
            ? ((totalUnits - vacantCount) / totalUnits).clamp(0.0, 1.0)
            : 0.0,
        currentProgressLabel: totalUnits > 0
            ? '${totalUnits - vacantCount} / $totalUnits'
            : '0/0',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final receiptProv = context.watch<ReceiptProvider>();
    final propertyProv = context.watch<PropertyProvider>();
    final isBn = appProv.isBn;
    final isDark = appProv.isDarkMode;

    final achievements = _computeAchievements(
      receiptCount: receiptProv.receipts.length,
      propertyCount: propertyProv.properties.length,
      vacantCount: propertyProv.totalVacantUnits,
      totalUnits: propertyProv.totalUnits,
    );

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🎖️',
                style: TextStyle(fontSize: 20 * appProv.fontScale),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appProv.tr('landlordMilestones'),
                  style: TextStyle(
                    fontSize: 16 * appProv.fontScale,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unlockedCount / ${achievements.length}',
                  style: TextStyle(
                    fontSize: 12 * appProv.fontScale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: achievements.map((achievement) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticService.selection();
                      _showBadgeDetail(context, achievement, isBn, isDark, appProv);
                    },
                    child: Container(
                      width: 130,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : (isDark ? Colors.grey[850] : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: achievement.isUnlocked
                              ? AppColors.primary.withValues(alpha: 0.4)
                              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                          width: achievement.isUnlocked ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            achievement.iconEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            achievement.getTitle(isBn),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12 * appProv.fontScale,
                              fontWeight: FontWeight.bold,
                              color: achievement.isUnlocked
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: achievement.progress,
                              minHeight: 5,
                              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                achievement.isUnlocked
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achievement.currentProgressLabel,
                            style: TextStyle(
                              fontSize: 10 * appProv.fontScale,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(
    BuildContext context,
    AchievementModel badge,
    bool isBn,
    bool isDark,
    AppProvider appProv,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.cardBackground,
        title: Column(
          children: [
            Text(badge.iconEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              badge.getTitle(isBn),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20 * appProv.fontScale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.getDescription(isBn),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15 * appProv.fontScale,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? AppColors.success.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.isUnlocked
                    ? (isBn ? '✅ আনলক সম্পন্ন!' : '✅ Unlocked!')
                    : (isBn ? '🔒 এখনও আনলক হয়নি' : '🔒 Locked'),
                style: TextStyle(
                  fontSize: 13 * appProv.fontScale,
                  fontWeight: FontWeight.bold,
                  color: badge.isUnlocked ? AppColors.success : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appProv.tr('close')),
          ),
        ],
      ),
    );
  }
}
