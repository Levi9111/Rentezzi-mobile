import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../core/services/pdf_service.dart';
import '../core/services/whatsapp_service.dart';
import '../models/receipt_model.dart';
import '../providers/app_provider.dart';
import '../providers/receipt_provider.dart';
import 'receipt_preview_sheet.dart';

class ReceiptCard extends StatelessWidget {
  final ReceiptModel receipt;
  final VoidCallback? onTap;

  const ReceiptCard({
    super.key,
    required this.receipt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;
    final totalFormatted = NumberFormat('#,##,###').format(receipt.totalAmount);
    final dateFormatted = DateFormat('dd MMM yyyy').format(receipt.createdAt);

    return InkWell(
      onTap: onTap ??
          () {
            HapticService.selection();
            ReceiptPreviewSheet.show(context, receipt);
          },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * fontScale),
        padding: EdgeInsets.all(16 * fontScale),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Tenant Name & Month badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receipt.tenantName,
                        style: TextStyle(
                          fontSize: 18 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3 * fontScale),
                      Text(
                        '${receipt.propertyName} • ${receipt.unitName}',
                        style: TextStyle(
                          fontSize: 13.5 * fontScale,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * fontScale,
                    vertical: 4 * fontScale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    receipt.month,
                    style: TextStyle(
                      fontSize: 12.5 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12 * fontScale),

            // Middle Row: Amount and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '৳',
                      style: TextStyle(
                        fontSize: 18 * fontScale,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(width: 4 * fontScale),
                    Text(
                      totalFormatted,
                      style: TextStyle(
                        fontSize: 22 * fontScale,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14 * fontScale),

            // Bottom Actions: WhatsApp, PDF, Delete
            Row(
              children: [
                // WhatsApp Button (Very prominent for elders!)
                Expanded(
                  child: SizedBox(
                    height: 44 * fontScale,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        HapticService.selection();
                        if (receipt.tenantPhone != null && receipt.tenantPhone!.isNotEmpty) {
                          await WhatsAppService.sendReceiptViaWhatsApp(
                            receipt: receipt,
                            tenantPhone: receipt.tenantPhone!,
                            isBn: app.isBn,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(app.tr('tenantPhoneHint')),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.chat_bubble_outline, size: 18 * fontScale),
                      label: Text(
                        app.tr('shareWhatsApp'),
                        style: TextStyle(
                          fontSize: 13.5 * fontScale,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsApp,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 10 * fontScale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8 * fontScale),

                // View / Print PDF Button
                SizedBox(
                  height: 44 * fontScale,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticService.selection();
                      PdfService.printOrShareReceipt(receipt);
                    },
                    icon: Icon(Icons.picture_as_pdf_outlined, size: 18 * fontScale),
                    label: Text(
                      app.tr('downloadPdf'),
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                      padding: EdgeInsets.symmetric(horizontal: 12 * fontScale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6 * fontScale),

                // Delete Button
                SizedBox(
                  height: 44 * fontScale,
                  width: 44 * fontScale,
                  child: IconButton(
                    onPressed: () {
                      HapticService.selection();
                      _confirmDelete(context, app);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20 * fontScale,
                      color: AppColors.destructive,
                    ),
                    tooltip: app.tr('deletePdf'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          app.tr('deletePdf'),
          style: TextStyle(
            fontSize: 18 * app.fontScale,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          app.tr('deleteConfirm'),
          style: TextStyle(fontSize: 15 * app.fontScale),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.light();
              Navigator.pop(ctx);
            },
            child: Text(
              app.tr('cancel'),
              style: TextStyle(fontSize: 15 * app.fontScale),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticService.medium();
              Navigator.pop(ctx);
              await context.read<ReceiptProvider>().deleteReceipt(receipt.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: Text(
              app.tr('confirm'),
              style: TextStyle(fontSize: 15 * app.fontScale),
            ),
          ),
        ],
      ),
    );
  }
}
