import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../core/services/pdf_service.dart';
import '../core/services/whatsapp_service.dart';
import '../models/receipt_model.dart';
import '../providers/app_provider.dart';
import 'elder_button.dart';

class CelebrationDialog extends StatefulWidget {
  final ReceiptModel receipt;
  final String? tenantPhone;

  const CelebrationDialog({
    super.key,
    required this.receipt,
    this.tenantPhone,
  });

  static Future<void> show(
    BuildContext context, {
    required ReceiptModel receipt,
    String? tenantPhone,
  }) {
    HapticService.success();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CelebrationDialog(
        receipt: receipt,
        tenantPhone: tenantPhone,
      ),
    );
  }

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final isBn = appProv.isBn;
    final isDark = appProv.isDarkMode;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.cardBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration badge icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🎉',
                    style: TextStyle(fontSize: 42),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appProv.tr('congratulations'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22 * appProv.fontScale,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appProv.tr('receiptCreatedCelebration'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15 * appProv.fontScale,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              // Amount pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.receipt.unitName ?? '',
                      style: TextStyle(
                        fontSize: 14 * appProv.fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '৳${widget.receipt.totalAmount.round()}',
                      style: TextStyle(
                        fontSize: 26 * appProv.fontScale,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // WhatsApp Share
              if (widget.tenantPhone != null && widget.tenantPhone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElderButton(
                    text: isBn ? 'হোয়াটসঅ্যাপে পাঠান' : 'Share via WhatsApp',
                    icon: Icons.send_rounded,
                    backgroundColor: AppColors.whatsappGreen,
                    onPressed: () async {
                      HapticService.selection();
                      await WhatsAppService.sendReceiptViaWhatsApp(
                        receipt: widget.receipt,
                        tenantPhone: widget.tenantPhone!,
                        isBn: isBn,
                      );
                    },
                  ),
                ),
              // PDF Share
              ElderButton(
                text: isBn ? 'রসিদ প্রিন্ট বা ডাউনলোড করুন' : 'Print or Download PDF',
                icon: Icons.print_rounded,
                isOutlined: true,
                onPressed: () async {
                  HapticService.selection();
                  await PdfService.printOrShareReceipt(widget.receipt);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  HapticService.light();
                  Navigator.of(context).pop();
                },
                child: Text(
                  appProv.tr('close'),
                  style: TextStyle(
                    fontSize: 16 * appProv.fontScale,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
