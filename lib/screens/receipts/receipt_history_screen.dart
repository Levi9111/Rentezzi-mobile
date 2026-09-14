import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/haptic_service.dart';
import '../../models/receipt_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/receipt_card.dart';

class ReceiptHistoryScreen extends StatefulWidget {
  const ReceiptHistoryScreen({super.key});

  @override
  State<ReceiptHistoryScreen> createState() => _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState extends State<ReceiptHistoryScreen> {
  final _searchController = TextEditingController();
  String _activeFilter = 'all'; // 'all', 'this_month', 'cash', 'bkash', 'bank'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReceiptModel> _applyFilters(List<ReceiptModel> receipts) {
    final now = DateTime.now();

    return receipts.where((r) {
      if (_activeFilter == 'this_month') {
        if (r.createdAt != null) {
          return r.createdAt!.year == now.year && r.createdAt!.month == now.month;
        }
        return true;
      } else if (_activeFilter == 'cash') {
        return r.paymentMethod.toLowerCase() == 'cash';
      } else if (_activeFilter == 'bkash') {
        final m = r.paymentMethod.toLowerCase();
        return m.contains('bkash') || m.contains('nagad') || m.contains('mobile');
      } else if (_activeFilter == 'bank') {
        final m = r.paymentMethod.toLowerCase();
        return m.contains('bank') || m.contains('cheque');
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final receipts = context.watch<ReceiptProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;

    final filteredList = _applyFilters(receipts.receipts);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          app.tr('historyTitle'),
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20 * fontScale),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => receipts.fetchReceipts(),
        color: AppColors.primary,
        child: Column(
          children: [
            // Search Input Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * fontScale, vertical: 10 * fontScale),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => receipts.setSearchQuery(val),
                style: TextStyle(fontSize: 16 * fontScale),
                decoration: InputDecoration(
                  hintText: app.isBengali ? 'ভাড়াটিয়া বা বাড়ির নাম দিয়ে খুঁজুন...' : 'Search by tenant, property or month...',
                  prefixIcon: Icon(Icons.search, size: 22 * fontScale),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            HapticService.selection();
                            _searchController.clear();
                            receipts.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 18 * fontScale),
              child: Row(
                children: [
                  _buildChip('all', app.tr('filterAll'), fontScale),
                  SizedBox(width: 8 * fontScale),
                  _buildChip('this_month', app.tr('filterThisMonth'), fontScale),
                  SizedBox(width: 8 * fontScale),
                  _buildChip('cash', app.isBengali ? 'নগদ (Cash)' : 'Cash', fontScale),
                  SizedBox(width: 8 * fontScale),
                  _buildChip('bkash', 'bKash / Nagad', fontScale),
                  SizedBox(width: 8 * fontScale),
                  _buildChip('bank', app.isBengali ? 'ব্যাংক' : 'Bank', fontScale),
                ],
              ),
            ),
            SizedBox(height: 10 * fontScale),

            // Receipts count badge
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * fontScale, vertical: 4 * fontScale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    app.tr('historyDesc'),
                    style: TextStyle(
                      fontSize: 13.5 * fontScale,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10 * fontScale, vertical: 3 * fontScale),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredList.length} ${app.tr('totalReceipts')}',
                      style: TextStyle(
                        fontSize: 12.5 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // Receipts List
            Expanded(
              child: receipts.isLoading && filteredList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(32 * fontScale),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64 * fontScale,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                                SizedBox(height: 16 * fontScale),
                                Text(
                                  app.tr('noHistory'),
                                  style: TextStyle(
                                    fontSize: 18 * fontScale,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                SizedBox(height: 8 * fontScale),
                                Text(
                                  app.tr('emptyReceiptsDesc'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.5 * fontScale,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 18 * fontScale, vertical: 8 * fontScale),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return ReceiptCard(receipt: filteredList[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String filterKey, String label, double fontScale) {
    final isSelected = _activeFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticService.selection();
          setState(() {
            _activeFilter = filterKey;
          });
        }
      },
      visualDensity: VisualDensity.compact,
      labelStyle: TextStyle(
        fontSize: 12.5 * fontScale,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : null,
      ),
    );
  }
}
