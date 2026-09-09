import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/elder_button.dart';
import '../../widgets/receipt_card.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    context.read<ReceiptProvider>().fetchReceipts();
    context.read<PropertyProvider>().fetchProperties();
    context.read<PropertyProvider>().fetchVacancySummary();
  }

  String _getGreeting(AppProvider app) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return app.tr('goodMorning');
    } else if (hour < 17) {
      return app.tr('goodAfternoon');
    } else {
      return app.tr('goodEvening');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final auth = context.watch<AuthProvider>();
    final receipts = context.watch<ReceiptProvider>();
    final properties = context.watch<PropertyProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;

    final landlordName = auth.user?.name ?? app.tr('landlordInfo');
    final greeting = _getGreeting(app);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
            ),
            SizedBox(width: 8 * fontScale),
            Text(
              'RENTEZZI',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 19 * fontScale,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Quick Language Toggle Chip
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * fontScale, horizontal: 8 * fontScale),
            child: ActionChip(
              avatar: Icon(Icons.language, size: 16 * fontScale, color: AppColors.primary),
              label: Text(
                app.isBengali ? 'EN' : 'বাং',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              onPressed: () => app.toggleLanguage(),
            ),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 22 * fontScale,
            ),
            tooltip: app.tr('theme'),
            onPressed: () => app.toggleTheme(),
          ),
          SizedBox(width: 4 * fontScale),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18 * fontScale, vertical: 14 * fontScale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20 * fontScale),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: TextStyle(
                        fontSize: 15 * fontScale,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4 * fontScale),
                    Text(
                      landlordName,
                      style: TextStyle(
                        fontSize: 22 * fontScale,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 14 * fontScale),

                    // Big Action Button: Create Rent Receipt
                    ElderButton(
                      label: app.tr('newReceipt'),
                      icon: Icons.add_circle_outline,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      height: 50 * fontScale,
                      onPressed: () => widget.onNavigateTab(1), // Switch to New Receipt Tab
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * fontScale),

              // Overview Title
              Text(
                app.tr('dashboard'),
                style: TextStyle(
                  fontSize: 19 * fontScale,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 12 * fontScale),

              // 2x2 Grid of Stat Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - (12 * fontScale)) / 2;
                  final totalRevenueFormatted =
                      '৳${NumberFormat('#,##,###').format(receipts.totalRevenue)}';

                  return Wrap(
                    spacing: 12 * fontScale,
                    runSpacing: 12 * fontScale,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: app.tr('totalReceipts'),
                          value: '${receipts.totalReceiptsCount}',
                          icon: Icons.receipt_long,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: app.tr('thisMonth'),
                          value: '${receipts.thisMonthCount}',
                          icon: Icons.calendar_today,
                          iconColor: AppColors.accent,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: app.tr('totalAmount'),
                          value: totalRevenueFormatted,
                          icon: Icons.account_balance_wallet_outlined,
                          iconColor: AppColors.amber,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: app.tr('vacantUnits'),
                          value: '${properties.vacantUnits}',
                          icon: Icons.meeting_room_outlined,
                          iconColor: properties.vacantUnits > 0
                              ? AppColors.warning
                              : AppColors.accent,
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 24 * fontScale),

              // Recent Activity Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    app.tr('recentActivity'),
                    style: TextStyle(
                      fontSize: 19 * fontScale,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (receipts.receipts.isNotEmpty)
                    TextButton(
                      onPressed: () => widget.onNavigateTab(2), // Switch to History Tab
                      child: Text(
                        app.isBengali ? 'সব দেখুন →' : 'View All →',
                        style: TextStyle(
                          fontSize: 14.5 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10 * fontScale),

              // Recent Receipts List
              if (receipts.isLoading && receipts.receipts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (receipts.receipts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24 * fontScale),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 48 * fontScale,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      SizedBox(height: 12 * fontScale),
                      Text(
                        app.tr('noHistory'),
                        style: TextStyle(
                          fontSize: 17 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 6 * fontScale),
                      Text(
                        app.tr('emptyReceiptsDesc'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...receipts.receipts.take(4).map(
                      (receipt) => ReceiptCard(receipt: receipt),
                    ),
              SizedBox(height: 16 * fontScale),
            ],
          ),
        ),
      ),
    );
  }
}
