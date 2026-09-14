import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../core/services/reminder_service.dart';
import '../models/property_model.dart';
import '../providers/app_provider.dart';
import 'elder_button.dart';

class TenantQuickActionsSheet extends StatefulWidget {
  final TenantModel tenant;
  final String unitName;
  final String propertyName;
  final double? rentAmount;

  const TenantQuickActionsSheet({
    super.key,
    required this.tenant,
    required this.unitName,
    required this.propertyName,
    this.rentAmount,
  });

  static void show(
    BuildContext context, {
    required TenantModel tenant,
    required String unitName,
    required String propertyName,
    double? rentAmount,
  }) {
    HapticService.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TenantQuickActionsSheet(
        tenant: tenant,
        unitName: unitName,
        propertyName: propertyName,
        rentAmount: rentAmount,
      ),
    );
  }

  @override
  State<TenantQuickActionsSheet> createState() => _TenantQuickActionsSheetState();
}

class _TenantQuickActionsSheetState extends State<TenantQuickActionsSheet> {
  ReminderTone _selectedTone = ReminderTone.friendly;

  Future<void> _makeCall(String phone) async {
    HapticService.medium();
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  Future<void> _sendSms(String phone) async {
    HapticService.medium();
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('sms:$cleanPhone');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final isBn = appProv.isBn;
    final isDark = appProv.isDarkMode;

    final currentMonth = isBn ? 'বর্তমান' : 'current';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          // Tenant Name & Details
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  widget.tenant.name.isNotEmpty
                      ? widget.tenant.name[0].toUpperCase()
                      : 'T',
                  style: TextStyle(
                    fontSize: 24 * appProv.fontScale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tenant.name,
                      style: TextStyle(
                        fontSize: 20 * appProv.fontScale,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${widget.propertyName} • ${widget.unitName}',
                      style: TextStyle(
                        fontSize: 14 * appProv.fontScale,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    if (widget.tenant.phone.isNotEmpty)
                      Text(
                        widget.tenant.phone,
                        style: TextStyle(
                          fontSize: 14 * appProv.fontScale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Call & SMS Action Buttons
          Row(
            children: [
              Expanded(
                child: ElderButton(
                  text: appProv.tr('callTenant'),
                  icon: Icons.phone_rounded,
                  backgroundColor: AppColors.success,
                  onPressed: widget.tenant.phone.isNotEmpty
                      ? () => _makeCall(widget.tenant.phone)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElderButton(
                  text: appProv.tr('smsTenant'),
                  icon: Icons.sms_rounded,
                  backgroundColor: AppColors.primary,
                  onPressed: widget.tenant.phone.isNotEmpty
                      ? () => _sendSms(widget.tenant.phone)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          const SizedBox(height: 8),
          // Rent Reminder Section
          Text(
            appProv.tr('sendReminder'),
            style: TextStyle(
              fontSize: 17 * appProv.fontScale,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Tone selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToneChip(
                  label: appProv.tr('toneFriendly'),
                  tone: ReminderTone.friendly,
                  appProv: appProv,
                ),
                const SizedBox(width: 8),
                _buildToneChip(
                  label: appProv.tr('toneFestive'),
                  tone: ReminderTone.festive,
                  appProv: appProv,
                ),
                const SizedBox(width: 8),
                _buildToneChip(
                  label: appProv.tr('toneStandard'),
                  tone: ReminderTone.standard,
                  appProv: appProv,
                ),
                const SizedBox(width: 8),
                _buildToneChip(
                  label: appProv.tr('toneUrgent'),
                  tone: ReminderTone.urgent,
                  appProv: appProv,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Send Reminder Button
          ElderButton(
            text: isBn ? 'হোয়াটসঅ্যাপে তাগাদা পাঠান' : 'Send WhatsApp Reminder',
            icon: Icons.send_rounded,
            backgroundColor: AppColors.whatsappGreen,
            onPressed: widget.tenant.phone.isNotEmpty
                ? () async {
                    HapticService.selection();
                    final message = ReminderService.generateMessage(
                      tenantName: widget.tenant.name,
                      propertyName: widget.propertyName,
                      unitName: widget.unitName,
                      month: currentMonth,
                      amount: widget.rentAmount ?? 0,
                      tone: _selectedTone,
                      isBn: isBn,
                    );
                    await ReminderService.sendWhatsAppReminder(
                      phone: widget.tenant.phone,
                      message: message,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                : null,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildToneChip({
    required String label,
    required ReminderTone tone,
    required AppProvider appProv,
  }) {
    final isSelected = _selectedTone == tone;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          HapticService.selection();
          setState(() {
            _selectedTone = tone;
          });
        }
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        fontSize: 13 * appProv.fontScale,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : null,
      ),
    );
  }
}
