import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/haptic_service.dart';
import '../../providers/app_provider.dart';
import '../../widgets/elder_button.dart';
import '../../widgets/elder_text_field.dart';
import '../receipts/rent_form_screen.dart';

class RentCalculatorScreen extends StatefulWidget {
  const RentCalculatorScreen({super.key});

  @override
  State<RentCalculatorScreen> createState() => _RentCalculatorScreenState();
}

class _RentCalculatorScreenState extends State<RentCalculatorScreen> {
  final _rentCtrl = TextEditingController(text: '15000');
  final _waterCtrl = TextEditingController(text: '500');
  final _gasCtrl = TextEditingController(text: '1080');
  final _electricityCtrl = TextEditingController(text: '1200');
  final _serviceCtrl = TextEditingController(text: '1500');
  final _garageCtrl = TextEditingController(text: '0');

  int _splitPersons = 1;

  double get _baseRent => double.tryParse(_rentCtrl.text) ?? 0;
  double get _water => double.tryParse(_waterCtrl.text) ?? 0;
  double get _gas => double.tryParse(_gasCtrl.text) ?? 0;
  double get _electricity => double.tryParse(_electricityCtrl.text) ?? 0;
  double get _service => double.tryParse(_serviceCtrl.text) ?? 0;
  double get _garage => double.tryParse(_garageCtrl.text) ?? 0;

  double get _totalRent =>
      _baseRent + _water + _gas + _electricity + _service + _garage;

  double get _perPersonRent => _totalRent / (_splitPersons > 0 ? _splitPersons : 1);

  @override
  void dispose() {
    _rentCtrl.dispose();
    _waterCtrl.dispose();
    _gasCtrl.dispose();
    _electricityCtrl.dispose();
    _serviceCtrl.dispose();
    _garageCtrl.dispose();
    super.dispose();
  }

  void _onFieldChanged(String _) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final isBn = appProv.isBn;
    final isDark = appProv.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appProv.tr('rentCalculator'),
          style: TextStyle(
            fontSize: 20 * appProv.fontScale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Total Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    appProv.tr('totalRentCalculated'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15 * appProv.fontScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '৳${_totalRent.round()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36 * appProv.fontScale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (_splitPersons > 1) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isBn
                            ? 'মাথাপিছু: ৳${_perPersonRent.round()} ($_splitPersons জন)'
                            : 'Per Person: ৳${_perPersonRent.round()} ($_splitPersons persons)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * appProv.fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Inputs
            Text(
              isBn ? 'বিল ও চার্জের বিবরণ' : 'Rent & Utility Breakdown',
              style: TextStyle(
                fontSize: 18 * appProv.fontScale,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ElderTextField(
              label: appProv.tr('baseRent'),
              controller: _rentCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.home_rounded,
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 14),
            ElderTextField(
              label: appProv.tr('waterSplit'),
              controller: _waterCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.water_drop_rounded,
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 14),
            ElderTextField(
              label: appProv.tr('gasSplit'),
              controller: _gasCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.local_fire_department_rounded,
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 14),
            ElderTextField(
              label: appProv.tr('electricitySplit'),
              controller: _electricityCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.bolt_rounded,
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 14),
            ElderTextField(
              label: appProv.tr('serviceCharge'),
              controller: _serviceCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.cleaning_services_rounded,
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 14),
            ElderTextField(
              label: appProv.tr('garageRent'),
              controller: _garageCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.directions_car_rounded,
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 20),
            // Split counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.group_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'ভাড়া ভাগাভাগি (জন)' : 'Split Rent (Persons)',
                          style: TextStyle(
                            fontSize: 14 * appProv.fontScale,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isBn ? 'ব্যাচেলর বা একাধিক সাবলেট' : 'For flatmates or sublets',
                          style: TextStyle(
                            fontSize: 12 * appProv.fontScale,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 28),
                    onPressed: _splitPersons > 1
                        ? () {
                            HapticService.selection();
                            setState(() {
                              _splitPersons--;
                            });
                          }
                        : null,
                  ),
                  Text(
                    '$_splitPersons',
                    style: TextStyle(
                      fontSize: 18 * appProv.fontScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 28),
                    onPressed: () {
                      HapticService.selection();
                      setState(() {
                        _splitPersons++;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action button to use in new receipt
            ElderButton(
              text: appProv.tr('applyToReceipt'),
              icon: Icons.receipt_long_rounded,
              backgroundColor: AppColors.success,
              onPressed: () {
                HapticService.medium();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const RentFormScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
