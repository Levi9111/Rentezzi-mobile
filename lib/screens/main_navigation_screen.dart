import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../providers/app_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'properties/properties_screen.dart';
import 'receipts/receipt_history_screen.dart';
import 'receipts/rent_form_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onNavigateTab(int index) {
    HapticService.selection();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;

    final pages = [
      DashboardScreen(onNavigateTab: _onNavigateTab),
      const RentFormScreen(),
      const ReceiptHistoryScreen(),
      const PropertiesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticService.selection();
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          selectedFontSize: 13 * fontScale,
          unselectedFontSize: 12 * fontScale,
          iconSize: 24 * fontScale,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard_rounded),
              label: app.tr('dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_circle_outline),
              activeIcon: const Icon(Icons.add_circle_rounded),
              label: app.tr('rentForm'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long_rounded),
              label: app.tr('history'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.apartment_outlined),
              activeIcon: const Icon(Icons.apartment_rounded),
              label: app.tr('properties'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: app.tr('settings'),
            ),
          ],
        ),
      ),
    );
  }
}
