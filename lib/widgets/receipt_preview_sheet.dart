import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../core/services/pdf_service.dart';
import '../core/services/whatsapp_service.dart';
import '../models/receipt_model.dart';
import '../providers/app_provider.dart';
import 'elder_button.dart';

class ReceiptPreviewSheet extends StatelessWidget {
  final ReceiptModel receipt;

  const ReceiptPreviewSheet({super.key, required this.receipt});

  static void show(BuildContext context, ReceiptModel receipt) {
    HapticService.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ReceiptPreviewSheet(receipt: receipt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final isBn = appProv.isBn;
    final isDark = appProv.isDarkMode;

    final dateStr = receipt.paymentDate.isNotEmpty
        ? receipt.paymentDate
        : DateFormat('dd MMM yyyy').format(receipt.createdAt);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'রসিদের বিবরণ' : 'Receipt Details',
                        style: TextStyle(
                          fontSize: 20 * appProv.fontScale,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        receipt.receiptNumber,
                        style: TextStyle(
                          fontSize: 12 * appProv.fontScale,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: appProv.tr('copiedToClipboard'),
                  onPressed: () {
                    HapticService.selection();
                    Clipboard.setData(ClipboardData(
                      text: 'Rentezzi Receipt: ${receipt.unitName} - ${receipt.tenantName} - ৳${receipt.totalAmount.round()} - $dateStr',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(appProv.tr('copiedToClipboard'))),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Receipt Card Mockup
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  _buildRow('Tenant', receipt.tenantName, isDark, appProv, isBold: true),
                  _buildRow('Property / Unit', '${receipt.propertyName} • ${receipt.unitName}', isDark, appProv),
                  _buildRow('Month', receipt.month, isDark, appProv),
                  _buildRow('Payment Date', dateStr, isDark, appProv),
                  _buildRow('Payment Method', receipt.paymentMethod.toUpperCase(), isDark, appProv),
                  const Divider(height: 24),
                  _buildRow('Base Rent', '৳${receipt.rentAmount.round()}', isDark, appProv),
                  if (receipt.waterBill != null && receipt.waterBill! > 0)
                    _buildRow('Water Bill', '৳${receipt.waterBill!.round()}', isDark, appProv),
                  if (receipt.gasBill != null && receipt.gasBill! > 0)
                    _buildRow('Gas Bill', '৳${receipt.gasBill!.round()}', isDark, appProv),
                  if (receipt.otherBills != null && receipt.otherBills! > 0)
                    _buildRow('Other Charges', '৳${receipt.otherBills!.round()}', isDark, appProv),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'মোট পরিশোধ' : 'Total Paid',
                        style: TextStyle(
                          fontSize: 18 * appProv.fontScale,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '৳${receipt.totalAmount.round()}',
                        style: TextStyle(
                          fontSize: 22 * appProv.fontScale,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElderButton(
                    text: isBn ? 'পিডিএফ রসিদ' : 'Print PDF',
                    icon: Icons.print_rounded,
                    backgroundColor: AppColors.primary,
                    onPressed: () async {
                      HapticService.selection();
                      await PdfService.printOrShareReceipt(receipt);
                    },
                  ),
                ),
                if (receipt.tenantPhone != null && receipt.tenantPhone!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElderButton(
                      text: 'WhatsApp',
                      icon: Icons.send_rounded,
                      backgroundColor: AppColors.whatsappGreen,
                      onPressed: () async {
                        HapticService.selection();
                        await WhatsAppService.sendReceiptViaWhatsApp(
                          receipt: receipt,
                          tenantPhone: receipt.tenantPhone!,
                          isBn: isBn,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark, AppProvider appProv, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * appProv.fontScale,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14 * appProv.fontScale,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
