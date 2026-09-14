class AchievementModel {
  final String id;
  final String titleEn;
  final String titleBn;
  final String descriptionEn;
  final String descriptionBn;
  final String iconEmoji;
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0
  final String currentProgressLabel;

  const AchievementModel({
    required this.id,
    required this.titleEn,
    required this.titleBn,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.iconEmoji,
    required this.isUnlocked,
    required this.progress,
    required this.currentProgressLabel,
  });

  String getTitle(bool isBn) => isBn ? titleBn : titleEn;
  String getDescription(bool isBn) => isBn ? descriptionBn : descriptionEn;
}
