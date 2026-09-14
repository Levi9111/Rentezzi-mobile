import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../models/property_model.dart';
import '../providers/app_provider.dart';
import '../providers/property_provider.dart';
import 'tenant_quick_actions.dart';

class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final VoidCallback onAddUnit;
  final Function(UnitModel) onEditTenant;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onAddUnit,
    required this.onEditTenant,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _isExpanded = false;
  String _unitFilter = 'all'; // 'all', 'occupied', 'vacant'

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;
    final prop = widget.property;

    final filteredUnits = prop.units.where((u) {
      if (_unitFilter == 'occupied') return u.isOccupied;
      if (_unitFilter == 'vacant') return !u.isOccupied;
      return true;
    }).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 14 * fontScale),
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
          // Header Section
          Padding(
            padding: EdgeInsets.all(16 * fontScale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prop.name,
                            style: TextStyle(
                              fontSize: 18.5 * fontScale,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 4 * fontScale),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 15 * fontScale,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                              SizedBox(width: 4 * fontScale),
                              Expanded(
                                child: Text(
                                  prop.address,
                                  style: TextStyle(
                                    fontSize: 13.5 * fontScale,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.destructive,
                        size: 22 * fontScale,
                      ),
                      onPressed: () {
                        HapticService.selection();
                        _confirmDeleteProperty(context, app);
                      },
                      tooltip: app.tr('deleteProperty'),
                    ),
                  ],
                ),
                SizedBox(height: 12 * fontScale),

                // Stats Row
                Row(
                  children: [
                    _buildBadge(
                      label: '${prop.totalUnits} ${app.tr('units')}',
                      color: AppColors.primary,
                      fontScale: fontScale,
                    ),
                    SizedBox(width: 8 * fontScale),
                    _buildBadge(
                      label: '${prop.occupiedUnits} ${app.tr('occupied')}',
                      color: AppColors.accent,
                      fontScale: fontScale,
                    ),
                    SizedBox(width: 8 * fontScale),
                    _buildBadge(
                      label: '${prop.vacantUnits} ${app.tr('vacant')}',
                      color: prop.vacantUnits > 0 ? AppColors.warning : AppColors.accent,
                      fontScale: fontScale,
                    ),
                  ],
                ),
                SizedBox(height: 8 * fontScale),

                // Expand / Collapse Toggle
                InkWell(
                  onTap: () {
                    HapticService.selection();
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4 * fontScale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isExpanded ? app.tr('hideUnits') : app.tr('viewUnits'),
                          style: TextStyle(
                            fontSize: 13.5 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppColors.primary,
                          size: 20 * fontScale,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Units Section (Collapsible)
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            Container(
              padding: EdgeInsets.all(16 * fontScale),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg.withValues(alpha: 0.5) : AppColors.lightBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        app.tr('units'),
                        style: TextStyle(
                          fontSize: 15 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          HapticService.selection();
                          widget.onAddUnit();
                        },
                        icon: Icon(Icons.add_circle_outline, size: 18 * fontScale),
                        label: Text(
                          app.tr('addUnit'),
                          style: TextStyle(fontSize: 13.5 * fontScale, fontWeight: FontWeight.w700),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  // Filter chips for units
                  if (prop.units.isNotEmpty) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', app.tr('filterAll'), fontScale),
                          SizedBox(width: 6 * fontScale),
                          _buildFilterChip('occupied', app.tr('filterOccupied'), fontScale),
                          SizedBox(width: 6 * fontScale),
                          _buildFilterChip('vacant', app.tr('filterVacant'), fontScale),
                        ],
                      ),
                    ),
                    SizedBox(height: 10 * fontScale),
                  ],

                  if (filteredUnits.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12 * fontScale),
                      child: Center(
                        child: Text(
                          prop.units.isEmpty ? app.tr('noUnitsYet') : 'No matching units found',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredUnits.map((unit) => _buildUnitItem(context, unit, app, fontScale, isDark)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, double fontScale) {
    final isSelected = _unitFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticService.selection();
          setState(() {
            _unitFilter = filterKey;
          });
        }
      },
      visualDensity: VisualDensity.compact,
      labelStyle: TextStyle(
        fontSize: 11.5 * fontScale,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : null,
      ),
    );
  }

  Widget _buildBadge({required String label, required Color color, required double fontScale}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * fontScale, vertical: 3 * fontScale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5 * fontScale,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildUnitItem(
    BuildContext context,
    UnitModel unit,
    AppProvider app,
    double fontScale,
    bool isDark,
  ) {
    final hasTenant = unit.isOccupied;
    final tenant = unit.tenant;

    return Container(
      margin: EdgeInsets.only(bottom: 10 * fontScale),
      padding: EdgeInsets.all(12 * fontScale),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.door_front_door_outlined,
                    size: 18 * fontScale,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6 * fontScale),
                  Text(
                    unit.name,
                    style: TextStyle(
                      fontSize: 15.5 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildBadge(
                    label: hasTenant ? app.tr('occupied') : app.tr('vacant'),
                    color: hasTenant ? AppColors.accent : AppColors.warning,
                    fontScale: fontScale,
                  ),
                  SizedBox(width: 4 * fontScale),
                  IconButton(
                    icon: Icon(Icons.close, size: 16 * fontScale, color: AppColors.destructive),
                    onPressed: () {
                      HapticService.selection();
                      _confirmDeleteUnit(context, unit, app);
                    },
                    tooltip: app.tr('deleteUnit'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),

          if (hasTenant && tenant != null) ...[
            SizedBox(height: 6 * fontScale),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${app.tr('tenantName')}: ${tenant.name}',
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        '${app.tr('phone')}: ${tenant.phone} • ৳${NumberFormat('#,##,###').format(tenant.rentAmount)}',
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick Call/Actions button
                IconButton(
                  icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.success),
                  tooltip: app.tr('callTenant'),
                  onPressed: () {
                    HapticService.medium();
                    TenantQuickActionsSheet.show(
                      context,
                      tenant: tenant,
                      unitName: unit.name,
                      propertyName: widget.property.name,
                      rentAmount: tenant.rentAmount.toDouble(),
                    );
                  },
                ),
              ],
            ),
          ],

          SizedBox(height: 8 * fontScale),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasTenant) ...[
                TextButton(
                  onPressed: () {
                    HapticService.selection();
                    _confirmClearTenant(context, unit, app);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.destructive,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    app.tr('clearTenant'),
                    style: TextStyle(fontSize: 13 * fontScale),
                  ),
                ),
                SizedBox(width: 6 * fontScale),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  HapticService.selection();
                  widget.onEditTenant(unit);
                },
                icon: Icon(
                  hasTenant ? Icons.edit_outlined : Icons.person_add_alt_1_outlined,
                  size: 15 * fontScale,
                ),
                label: Text(
                  hasTenant ? app.tr('editTenant') : app.tr('addTenant'),
                  style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, 36 * fontScale),
                  padding: EdgeInsets.symmetric(horizontal: 12 * fontScale),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProperty(BuildContext context, AppProvider app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(app.tr('deleteProperty'), style: TextStyle(fontSize: 18 * app.fontScale, fontWeight: FontWeight.w700)),
        content: Text(app.tr('deletePropertyConfirm'), style: TextStyle(fontSize: 15 * app.fontScale)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(app.tr('cancel'))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<PropertyProvider>().deleteProperty(widget.property.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive, foregroundColor: Colors.white),
            child: Text(app.tr('confirm')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUnit(BuildContext context, UnitModel unit, AppProvider app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(app.tr('deleteUnit'), style: TextStyle(fontSize: 18 * app.fontScale, fontWeight: FontWeight.w700)),
        content: Text(app.tr('deleteUnitConfirm'), style: TextStyle(fontSize: 15 * app.fontScale)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(app.tr('cancel'))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<PropertyProvider>().deleteUnit(propertyId: widget.property.id, unitId: unit.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive, foregroundColor: Colors.white),
            child: Text(app.tr('confirm')),
          ),
        ],
      ),
    );
  }

  void _confirmClearTenant(BuildContext context, UnitModel unit, AppProvider app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(app.tr('clearTenant'), style: TextStyle(fontSize: 18 * app.fontScale, fontWeight: FontWeight.w700)),
        content: Text(app.tr('tenantCleared'), style: TextStyle(fontSize: 15 * app.fontScale)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(app.tr('cancel'))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<PropertyProvider>().clearTenant(propertyId: widget.property.id, unitId: unit.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive, foregroundColor: Colors.white),
            child: Text(app.tr('confirm')),
          ),
        ],
      ),
    );
  }
}
