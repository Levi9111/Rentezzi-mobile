import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/property_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/elder_button.dart';
import '../../widgets/elder_text_field.dart';
import '../../widgets/property_card.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().fetchProperties();
      context.read<PropertyProvider>().fetchVacancySummary();
    });
  }

  void _showAddPropertyDialog() {
    final app = context.read<AppProvider>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          app.tr('addProperty'),
          style: TextStyle(
            fontSize: 18.5 * app.fontScale,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElderTextField(
                label: app.tr('propertyName'),
                hintText: app.tr('propertyNameHint'),
                controller: nameController,
                prefixIcon: Icons.apartment,
              ),
              SizedBox(height: 14 * app.fontScale),
              ElderTextField(
                label: app.tr('addressLabel'),
                hintText: app.tr('addressHint'),
                controller: addressController,
                prefixIcon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(app.tr('cancel'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || addressController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final success = await context.read<PropertyProvider>().createProperty(
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                  );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(app.tr('propertyAdded')), backgroundColor: AppColors.success),
                );
              }
            },
            child: Text(app.tr('confirm'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
        ],
      ),
    );
  }

  void _showAddUnitDialog(PropertyModel property) {
    final app = context.read<AppProvider>();
    final unitNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${app.tr('addUnit')} (${property.name})',
          style: TextStyle(
            fontSize: 18 * app.fontScale,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: ElderTextField(
          label: app.tr('unitName'),
          hintText: app.tr('unitPlaceholder'),
          controller: unitNameController,
          prefixIcon: Icons.door_front_door_outlined,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(app.tr('cancel'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (unitNameController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await context.read<PropertyProvider>().addUnit(
                    propertyId: property.id,
                    name: unitNameController.text.trim(),
                  );
            },
            child: Text(app.tr('confirm'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
        ],
      ),
    );
  }

  void _showTenantDialog(PropertyModel property, UnitModel unit) {
    final app = context.read<AppProvider>();
    final isEdit = unit.isOccupied;
    final currentTenant = unit.tenant;

    final nameController = TextEditingController(text: currentTenant?.name ?? '');
    final phoneController = TextEditingController(text: currentTenant?.phone ?? '');
    final rentController = TextEditingController(
      text: (currentTenant?.rentAmount != null && currentTenant!.rentAmount > 0)
          ? currentTenant.rentAmount.toString()
          : '',
    );
    final waterController = TextEditingController(
      text: (currentTenant?.waterBill != null && currentTenant!.waterBill! > 0)
          ? currentTenant.waterBill.toString()
          : '',
    );
    final gasController = TextEditingController(
      text: (currentTenant?.gasBill != null && currentTenant!.gasBill! > 0)
          ? currentTenant.gasBill.toString()
          : '',
    );
    final otherController = TextEditingController(
      text: (currentTenant?.otherBills != null && currentTenant!.otherBills! > 0)
          ? currentTenant.otherBills.toString()
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isEdit ? app.tr('editTenant') : app.tr('addTenant'),
          style: TextStyle(
            fontSize: 18.5 * app.fontScale,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElderTextField(
                label: app.tr('tenantName'),
                hintText: app.tr('tenantNameHint'),
                controller: nameController,
                prefixIcon: Icons.person_outline,
              ),
              SizedBox(height: 12 * app.fontScale),
              ElderTextField(
                label: app.tr('tenantPhone'),
                hintText: app.tr('tenantPhoneHint'),
                controller: phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android_outlined,
              ),
              SizedBox(height: 12 * app.fontScale),
              ElderTextField(
                label: app.tr('rentAmount'),
                hintText: 'e.g. 15000',
                controller: rentController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),
              SizedBox(height: 12 * app.fontScale),
              Row(
                children: [
                  Expanded(
                    child: ElderTextField(
                      label: app.tr('waterBill'),
                      hintText: '0',
                      controller: waterController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 8 * app.fontScale),
                  Expanded(
                    child: ElderTextField(
                      label: app.tr('gasBill'),
                      hintText: '0',
                      controller: gasController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * app.fontScale),
              ElderTextField(
                label: app.tr('otherBills'),
                hintText: '0',
                controller: otherController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(app.tr('cancel'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;
              Navigator.pop(ctx);

              final newTenant = TenantModel(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                rentAmount: num.tryParse(rentController.text) ?? 0,
                waterBill: num.tryParse(waterController.text) ?? 0,
                gasBill: num.tryParse(gasController.text) ?? 0,
                otherBills: num.tryParse(otherController.text) ?? 0,
              );

              final success = await context.read<PropertyProvider>().assignTenant(
                    propertyId: property.id,
                    unitId: unit.id,
                    tenant: newTenant,
                  );

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(app.tr('tenantAdded')), backgroundColor: AppColors.success),
                );
              }
            },
            child: Text(app.tr('confirm'), style: TextStyle(fontSize: 15 * app.fontScale)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final properties = context.watch<PropertyProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          app.tr('myProperties'),
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20 * fontScale),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showAddPropertyDialog,
            icon: Icon(Icons.add, size: 20 * fontScale),
            label: Text(
              app.tr('addProperty'),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14 * fontScale),
            ),
          ),
          SizedBox(width: 8 * fontScale),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await properties.fetchProperties();
          await properties.fetchVacancySummary();
        },
        color: AppColors.primary,
        child: properties.isLoading && properties.properties.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : properties.properties.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(32 * fontScale),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apartment_outlined,
                            size: 64 * fontScale,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          SizedBox(height: 16 * fontScale),
                          Text(
                            app.tr('noProperties'),
                            style: TextStyle(
                              fontSize: 18 * fontScale,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 20 * fontScale),
                          ElderButton(
                            label: app.tr('addProperty'),
                            icon: Icons.add_home_work,
                            onPressed: _showAddPropertyDialog,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 18 * fontScale, vertical: 14 * fontScale),
                    itemCount: properties.properties.length,
                    itemBuilder: (context, index) {
                      final prop = properties.properties[index];
                      return PropertyCard(
                        property: prop,
                        onAddUnit: () => _showAddUnitDialog(prop),
                        onEditTenant: (unit) => _showTenantDialog(prop, unit),
                      );
                    },
                  ),
      ),
    );
  }
}
