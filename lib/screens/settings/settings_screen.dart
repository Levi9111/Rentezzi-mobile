import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/haptic_service.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/elder_button.dart';
import '../../widgets/elder_text_field.dart';
import '../../widgets/emergency_sheet.dart';
import '../auth/login_screen.dart';
import '../tools/rent_calculator_screen.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showEditNameDialog(BuildContext context, AuthProvider auth, AppProvider app) {
    HapticService.selection();
    final controller = TextEditingController(text: auth.user?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          app.tr('editNameBtn'),
          style: TextStyle(
            fontSize: 18.5 * app.fontScale,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: ElderTextField(
          label: app.tr('landlordName'),
          hintText: app.tr('namePlaceholder'),
          controller: controller,
          prefixIcon: Icons.badge_outlined,
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.light();
              Navigator.pop(ctx);
            },
            child: Text(app.tr('cancel'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              HapticService.medium();
              Navigator.pop(ctx);
              await auth.updateName(controller.text.trim());
            },
            child: Text(app.tr('confirm'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, AuthProvider auth, AppProvider app) {
    HapticService.selection();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          app.tr('logout'),
          style: TextStyle(
            fontSize: 18.5 * app.fontScale,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          app.tr('logoutConfirm'),
          style: TextStyle(fontSize: 15.5 * app.fontScale),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.light();
              Navigator.pop(ctx);
            },
            child: Text(app.tr('cancel'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticService.heavy();
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: Text(app.tr('logout'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final auth = context.watch<AuthProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;

    final userName = auth.user?.name ?? app.tr('addYourName');
    final userPhone = auth.user?.phone ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          app.tr('settings'),
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20 * fontScale),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18 * fontScale, vertical: 14 * fontScale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header Card
            Container(
              padding: EdgeInsets.all(16 * fontScale),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28 * fontScale,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.person,
                      size: 32 * fontScale,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 14 * fontScale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: 3 * fontScale),
                        Text(
                          userPhone,
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 22 * fontScale, color: AppColors.primary),
                    onPressed: () => _showEditNameDialog(context, auth, app),
                    tooltip: app.tr('editNameBtn'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18 * fontScale),

            // Elder Accessibility & Font Size Card
            _buildCard(
              title: app.tr('accessibility'),
              icon: Icons.accessibility_new_rounded,
              isDark: isDark,
              fontScale: fontScale,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: app.isElderMode,
                  activeTrackColor: AppColors.primary,
                  title: Text(
                    app.tr('elderMode'),
                    style: TextStyle(
                      fontSize: 16 * fontScale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    app.tr('elderModeSubtitle'),
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  onChanged: (_) {
                    HapticService.selection();
                    app.toggleElderMode();
                  },
                ),
                const Divider(height: 16),
                // Haptic Feedback Switch
                StatefulBuilder(
                  builder: (context, setLocalState) {
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: HapticService.enabled,
                      activeTrackColor: AppColors.primary,
                      title: Text(
                        app.tr('hapticFeedback'),
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        app.tr('hapticFeedbackDesc'),
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      onChanged: (val) {
                        setLocalState(() {
                          HapticService.enabled = val;
                        });
                        if (val) HapticService.success();
                      },
                    );
                  },
                ),
                const Divider(height: 16),
                Text(
                  app.tr('textSize'),
                  style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10 * fontScale),
                Row(
                  children: [
                    _buildScaleOption(app, 1.0, app.tr('normal'), fontScale),
                    SizedBox(width: 8 * fontScale),
                    _buildScaleOption(app, 1.18, app.tr('large'), fontScale),
                    SizedBox(width: 8 * fontScale),
                    _buildScaleOption(app, 1.35, app.tr('extraLarge'), fontScale),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16 * fontScale),

            // Quick Tools & Utilities Card
            _buildCard(
              title: app.isBengali ? 'সহজ টুলস ও হেল্পলাইন' : 'Quick Tools & Utilities',
              icon: Icons.construction_rounded,
              isDark: isDark,
              fontScale: fontScale,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calculate_outlined, color: AppColors.primary),
                  ),
                  title: Text(
                    app.tr('rentCalculator'),
                    style: TextStyle(fontSize: 15.5 * fontScale, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    app.tr('rentCalculatorSubtitle'),
                    style: TextStyle(fontSize: 12 * fontScale, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticService.selection();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RentCalculatorScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.warning),
                  ),
                  title: Text(
                    app.tr('emergencyHelplines'),
                    style: TextStyle(fontSize: 15.5 * fontScale, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    app.tr('emergencyHelplinesSubtitle'),
                    style: TextStyle(fontSize: 12 * fontScale, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticService.selection();
                    EmergencyHelplineSheet.show(context);
                  },
                ),
              ],
            ),

            SizedBox(height: 16 * fontScale),

            // Language & Theme Card
            _buildCard(
              title: '${app.tr('language')} & ${app.tr('theme')}',
              icon: Icons.tune,
              isDark: isDark,
              fontScale: fontScale,
              children: [
                // Language
                Text(
                  app.tr('language'),
                  style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8 * fontScale),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(app.tr('bangla'))),
                        selected: app.isBengali,
                        onSelected: (val) {
                          if (val) {
                            HapticService.selection();
                            app.setLanguage('bn');
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12 * fontScale),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(app.tr('english'))),
                        selected: !app.isBengali,
                        onSelected: (val) {
                          if (val) {
                            HapticService.selection();
                            app.setLanguage('en');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Theme Mode
                Text(
                  app.tr('theme'),
                  style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8 * fontScale),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(app.tr('light'))),
                        selected: !app.isDarkMode,
                        onSelected: (val) {
                          if (val) {
                            HapticService.selection();
                            app.setThemeMode(ThemeMode.light);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12 * fontScale),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(app.tr('dark'))),
                        selected: app.isDarkMode,
                        onSelected: (val) {
                          if (val) {
                            HapticService.selection();
                            app.setThemeMode(ThemeMode.dark);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16 * fontScale),

            // Legal & Info Card
            _buildCard(
              title: app.tr('about'),
              icon: Icons.info_outline,
              isDark: isDark,
              fontScale: fontScale,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(
                    app.tr('privacyPolicy'),
                    style: TextStyle(fontSize: 15.5 * fontScale, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticService.selection();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LegalScreen(title: app.tr('privacyPolicy'), isPrivacy: true),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    app.tr('termsOfService'),
                    style: TextStyle(fontSize: 15.5 * fontScale, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticService.selection();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LegalScreen(title: app.tr('termsOfService'), isPrivacy: false),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: EdgeInsets.only(top: 10 * fontScale),
                  child: Text(
                    '${app.tr('brand')} — ${app.tr('version')}',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24 * fontScale),

            // Logout Button
            ElderButton(
              label: app.tr('logout'),
              icon: Icons.logout_rounded,
              backgroundColor: AppColors.destructive,
              onPressed: () => _showLogoutConfirm(context, auth, app),
            ),
            SizedBox(height: 24 * fontScale),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required double fontScale,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * fontScale),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20 * fontScale, color: AppColors.primary),
              SizedBox(width: 8 * fontScale),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.5 * fontScale,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildScaleOption(AppProvider app, double scale, String label, double fontScale) {
    final isSelected = (app.fontScale - scale).abs() < 0.05;
    return Expanded(
      child: ChoiceChip(
        label: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        selected: isSelected,
        onSelected: (val) {
          if (val) {
            HapticService.selection();
            app.setFontScale(scale);
          }
        },
      ),
    );
  }
}
