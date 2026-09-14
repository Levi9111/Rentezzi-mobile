import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/whatsapp_service.dart';
import '../../models/property_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/celebration_dialog.dart';
import '../../widgets/elder_button.dart';
import '../../widgets/elder_text_field.dart';

class RentFormScreen extends StatefulWidget {
  const RentFormScreen({super.key});

  @override
  State<RentFormScreen> createState() => _RentFormScreenState();
}

class _RentFormScreenState extends State<RentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selected property & unit
  PropertyModel? _selectedProperty;
  UnitModel? _selectedUnit;
  bool _autoFilled = false;

  // Form Controllers
  final _tenantNameController = TextEditingController();
  final _tenantPhoneController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _rentAmountController = TextEditingController();
  final _waterBillController = TextEditingController();
  final _gasBillController = TextEditingController();
  final _otherBillsController = TextEditingController();
  final _landlordNameController = TextEditingController();
  final _landlordPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  String _monthYear = DateFormat('MMMM yyyy').format(DateTime.now());
  String _paymentMethod = 'cash'; // 'cash', 'bank_transfer', 'mobile_banking'
  String _receiptLang = 'bn';
  bool _shareWhatsApp = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _landlordNameController.text = auth.user?.name ?? '';
    _landlordPhoneController.text = auth.user?.phone ?? '';
    _receiptLang = context.read<AppProvider>().isBengali ? 'bn' : 'en';
  }

  @override
  void dispose() {
    _tenantNameController.dispose();
    _tenantPhoneController.dispose();
    _propertyAddressController.dispose();
    _rentAmountController.dispose();
    _waterBillController.dispose();
    _gasBillController.dispose();
    _otherBillsController.dispose();
    _landlordNameController.dispose();
    _landlordPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  num get _totalCalculatedAmount {
    num rent = num.tryParse(_rentAmountController.text) ?? 0;
    num water = num.tryParse(_waterBillController.text) ?? 0;
    num gas = num.tryParse(_gasBillController.text) ?? 0;
    num other = num.tryParse(_otherBillsController.text) ?? 0;
    return rent + water + gas + other;
  }

  void _onPropertySelected(PropertyModel? prop) {
    setState(() {
      _selectedProperty = prop;
      _selectedUnit = null;
      _autoFilled = false;
      if (prop != null) {
        _propertyAddressController.text = prop.address;
      }
    });
  }

  void _onUnitSelected(UnitModel? unit) {
    setState(() {
      _selectedUnit = unit;
      if (unit != null && unit.tenant != null) {
        final t = unit.tenant!;
        _tenantNameController.text = t.name;
        _tenantPhoneController.text = t.phone;
        _rentAmountController.text = t.rentAmount > 0 ? t.rentAmount.toString() : '';
        _waterBillController.text = (t.waterBill != null && t.waterBill! > 0) ? t.waterBill.toString() : '';
        _gasBillController.text = (t.gasBill != null && t.gasBill! > 0) ? t.gasBill.toString() : '';
        _otherBillsController.text = (t.otherBills != null && t.otherBills! > 0) ? t.otherBills.toString() : '';
        _autoFilled = true;
      } else {
        _autoFilled = false;
      }
    });
  }

  Future<void> _pickPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppProvider>();
    final receiptProvider = context.read<ReceiptProvider>();

    final payload = {
      'tenantName': _tenantNameController.text.trim(),
      'tenantPhone': _tenantPhoneController.text.trim(),
      'propertyId': _selectedProperty?.id,
      'propertyName': _selectedProperty?.name,
      'unitId': _selectedUnit?.id,
      'unitName': _selectedUnit?.name,
      'propertyAddress': _propertyAddressController.text.trim(),
      'rentAmount': num.tryParse(_rentAmountController.text) ?? 0,
      'waterBill': num.tryParse(_waterBillController.text) ?? 0,
      'gasBill': num.tryParse(_gasBillController.text) ?? 0,
      'otherBills': num.tryParse(_otherBillsController.text) ?? 0,
      'totalAmount': _totalCalculatedAmount,
      'monthYear': _monthYear,
      'paymentDate': DateFormat('dd/MM/yyyy').format(_paymentDate),
      'paymentMethod': _paymentMethod,
      'landlordName': _landlordNameController.text.trim(),
      'landlordPhone': _landlordPhoneController.text.trim(),
      'notes': _notesController.text.trim(),
      'receiptLang': _receiptLang,
    };

    final createdReceipt = await receiptProvider.createReceipt(payload);

    if (createdReceipt != null && mounted) {
      HapticService.success();
      // Show celebratory congratulations modal
      await CelebrationDialog.show(
        context,
        receipt: createdReceipt,
        tenantPhone: _tenantPhoneController.text.trim(),
      );
    } else if (mounted && receiptProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(receiptProvider.errorMessage!),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final properties = context.watch<PropertyProvider>();
    final receipts = context.watch<ReceiptProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          app.tr('formTitle'),
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20 * fontScale),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18 * fontScale, vertical: 14 * fontScale),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Description
              Text(
                app.tr('formDesc'),
                style: TextStyle(
                  fontSize: 14.5 * fontScale,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              SizedBox(height: 18 * fontScale),

              // Property & Unit Card
              _buildSectionCard(
                title: app.tr('propertyDetails'),
                icon: Icons.apartment,
                app: app,
                fontScale: fontScale,
                isDark: isDark,
                children: [
                  // Property Dropdown
                  Text(
                    app.tr('selectProperty'),
                    style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8 * fontScale),
                  DropdownButtonFormField<PropertyModel>(
                    value: _selectedProperty,
                    decoration: const InputDecoration(),
                    hint: Text(app.tr('selectProperty')),
                    items: properties.properties.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text('${p.name} (${p.totalUnits} ${app.tr('units')})'),
                      );
                    }).toList(),
                    onChanged: _onPropertySelected,
                  ),
                  SizedBox(height: 16 * fontScale),

                  // Unit Dropdown
                  Text(
                    app.tr('selectUnit'),
                    style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8 * fontScale),
                  DropdownButtonFormField<UnitModel>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(),
                    hint: Text(app.tr('selectUnit')),
                    items: (_selectedProperty?.units ?? []).map((u) {
                      return DropdownMenuItem(
                        value: u,
                        child: Text(
                          '${u.name} ${u.isOccupied ? "(${u.tenant?.name})" : "(${app.tr('vacant')})"}',
                        ),
                      );
                    }).toList(),
                    onChanged: _selectedProperty == null ? null : _onUnitSelected,
                  ),

                  // Auto fill notice chip
                  if (_autoFilled) ...[
                    SizedBox(height: 12 * fontScale),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * fontScale, vertical: 8 * fontScale),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bolt, size: 18 * fontScale, color: AppColors.accent),
                          SizedBox(width: 8 * fontScale),
                          Expanded(
                            child: Text(
                              app.tr('quickFill'),
                              style: TextStyle(
                                fontSize: 13 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 16 * fontScale),
                  ElderTextField(
                    label: app.tr('propertyAddress'),
                    hintText: app.tr('addressHint'),
                    controller: _propertyAddressController,
                    prefixIcon: Icons.location_on_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? app.tr('propertyAddress') : null,
                  ),
                ],
              ),

              SizedBox(height: 16 * fontScale),

              // Tenant Details Card
              _buildSectionCard(
                title: app.tr('tenantName'),
                icon: Icons.person_outline,
                app: app,
                fontScale: fontScale,
                isDark: isDark,
                children: [
                  ElderTextField(
                    label: app.tr('tenantName'),
                    hintText: app.tr('tenantNameHint'),
                    controller: _tenantNameController,
                    prefixIcon: Icons.badge_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? app.tr('tenantName') : null,
                  ),
                  SizedBox(height: 14 * fontScale),
                  ElderTextField(
                    label: app.tr('tenantPhone'),
                    hintText: app.tr('tenantPhoneHint'),
                    controller: _tenantPhoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_android_outlined,
                  ),
                ],
              ),

              SizedBox(height: 16 * fontScale),

              // Billing Details Card
              _buildSectionCard(
                title: app.tr('billingDetails'),
                icon: Icons.payments_outlined,
                app: app,
                fontScale: fontScale,
                isDark: isDark,
                children: [
                  ElderTextField(
                    label: app.tr('rentAmount'),
                    hintText: 'e.g. 15000',
                    controller: _rentAmountController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => (v == null || v.trim().isEmpty) ? app.tr('rentAmount') : null,
                  ),
                  SizedBox(height: 14 * fontScale),
                  Row(
                    children: [
                      Expanded(
                        child: ElderTextField(
                          label: app.tr('waterBill'),
                          hintText: '0',
                          controller: _waterBillController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      SizedBox(width: 12 * fontScale),
                      Expanded(
                        child: ElderTextField(
                          label: app.tr('gasBill'),
                          hintText: '0',
                          controller: _gasBillController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14 * fontScale),
                  ElderTextField(
                    label: app.tr('otherBills'),
                    hintText: '0',
                    controller: _otherBillsController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 16 * fontScale),

                  // Total Calculated Amount Card
                  Container(
                    padding: EdgeInsets.all(16 * fontScale),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          app.tr('totalAmount'),
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        Text(
                          '৳${NumberFormat('#,##,###').format(_totalCalculatedAmount)}',
                          style: TextStyle(
                            fontSize: 24 * fontScale,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16 * fontScale),

              // Payment & Month Details Card
              _buildSectionCard(
                title: app.tr('paymentInfo'),
                icon: Icons.calendar_month_outlined,
                app: app,
                fontScale: fontScale,
                isDark: isDark,
                children: [
                  // Month Year
                  ElderTextField(
                    label: app.tr('monthYear'),
                    hintText: 'e.g. September 2026',
                    controller: TextEditingController(text: _monthYear),
                    prefixIcon: Icons.date_range,
                    onChanged: (v) => _monthYear = v,
                  ),
                  SizedBox(height: 14 * fontScale),

                  // Payment Date Picker
                  Text(
                    app.tr('paymentDate'),
                    style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8 * fontScale),
                  InkWell(
                    onTap: _pickPaymentDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16 * fontScale, vertical: 14 * fontScale),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMMM yyyy').format(_paymentDate),
                            style: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w600),
                          ),
                          Icon(Icons.calendar_today, size: 20 * fontScale, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * fontScale),

                  // Payment Method Selector
                  Text(
                    app.tr('paymentMethod'),
                    style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8 * fontScale),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    decoration: const InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'cash', child: Text(app.tr('cash'))),
                      DropdownMenuItem(value: 'bank_transfer', child: Text(app.tr('bankTransfer'))),
                      DropdownMenuItem(value: 'mobile_banking', child: Text(app.tr('mobileBanking'))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentMethod = val);
                    },
                  ),
                ],
              ),

              SizedBox(height: 16 * fontScale),

              // Landlord & Receipt Settings
              _buildSectionCard(
                title: app.tr('landlordInfo'),
                icon: Icons.shield_outlined,
                app: app,
                fontScale: fontScale,
                isDark: isDark,
                children: [
                  ElderTextField(
                    label: app.tr('landlordName'),
                    hintText: app.tr('landlordName'),
                    controller: _landlordNameController,
                    prefixIcon: Icons.account_circle_outlined,
                  ),
                  SizedBox(height: 14 * fontScale),
                  ElderTextField(
                    label: app.tr('landlordPhone'),
                    hintText: app.tr('phoneHint'),
                    controller: _landlordPhoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                  ),
                  SizedBox(height: 14 * fontScale),
                  ElderTextField(
                    label: app.tr('notes'),
                    hintText: app.tr('notesHint'),
                    controller: _notesController,
                    maxLines: 2,
                    prefixIcon: Icons.note_alt_outlined,
                  ),
                  SizedBox(height: 14 * fontScale),

                  // Receipt Language Option
                  Text(
                    app.tr('receiptLanguage'),
                    style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8 * fontScale),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: Text(app.tr('bangla'))),
                          selected: _receiptLang == 'bn',
                          onSelected: (selected) {
                            if (selected) setState(() => _receiptLang = 'bn');
                          },
                        ),
                      ),
                      SizedBox(width: 12 * fontScale),
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: Text(app.tr('english'))),
                          selected: _receiptLang == 'en',
                          onSelected: (selected) {
                            if (selected) setState(() => _receiptLang = 'en');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 18 * fontScale),

              // WhatsApp Auto-share toggle
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _shareWhatsApp,
                activeColor: AppColors.whatsApp,
                title: Text(
                  app.tr('sendViaWhatsApp'),
                  style: TextStyle(
                    fontSize: 15.5 * fontScale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  app.tr('shareWhatsApp'),
                  style: TextStyle(
                    fontSize: 13.5 * fontScale,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                onChanged: (val) => setState(() => _shareWhatsApp = val ?? true),
              ),

              SizedBox(height: 20 * fontScale),

              // Submit / Generate Button
              ElderButton(
                label: app.tr('generatePdf'),
                icon: Icons.check_circle_outline,
                isLoading: receipts.isLoading,
                backgroundColor: AppColors.primary,
                height: 56 * fontScale,
                onPressed: _handleSubmit,
              ),

              SizedBox(height: 32 * fontScale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required AppProvider app,
    required double fontScale,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
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
                  fontSize: 17 * fontScale,
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
}
