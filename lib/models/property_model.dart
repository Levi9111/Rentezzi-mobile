class TenantModel {
  final String name;
  final String phone;
  final num rentAmount;
  final num? waterBill;
  final num? gasBill;
  final num? otherBills;

  TenantModel({
    required this.name,
    required this.phone,
    required this.rentAmount,
    this.waterBill,
    this.gasBill,
    this.otherBills,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      rentAmount: json['rentAmount'] ?? 0,
      waterBill: json['waterBill'],
      gasBill: json['gasBill'],
      otherBills: json['otherBills'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'rentAmount': rentAmount,
      'waterBill': waterBill,
      'gasBill': gasBill,
      'otherBills': otherBills,
    };
  }
}

class UnitModel {
  final String id;
  final String name;
  final TenantModel? tenant;

  UnitModel({
    required this.id,
    required this.name,
    this.tenant,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      tenant: json['tenant'] != null && json['tenant'] is Map<String, dynamic>
          ? TenantModel.fromJson(json['tenant'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tenant': tenant?.toJson(),
    };
  }

  bool get isOccupied => tenant != null && tenant!.name.isNotEmpty;
}

class PropertyModel {
  final String id;
  final String name;
  final String address;
  final List<UnitModel> units;
  final DateTime? createdAt;

  PropertyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.units,
    this.createdAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final rawUnits = json['units'] as List<dynamic>? ?? [];
    return PropertyModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      units: rawUnits
          .whereType<Map<String, dynamic>>()
          .map((u) => UnitModel.fromJson(u))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'units': units.map((u) => u.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  int get totalUnits => units.length;
  int get occupiedUnits => units.where((u) => u.isOccupied).length;
  int get vacantUnits => totalUnits - occupiedUnits;
}

class VacancySummaryModel {
  final int totalUnits;
  final int occupiedUnits;
  final int vacantUnits;

  VacancySummaryModel({
    required this.totalUnits,
    required this.occupiedUnits,
    required this.vacantUnits,
  });

  factory VacancySummaryModel.fromJson(Map<String, dynamic> json) {
    return VacancySummaryModel(
      totalUnits: json['totalUnits'] ?? 0,
      occupiedUnits: json['occupiedUnits'] ?? 0,
      vacantUnits: json['vacantUnits'] ?? 0,
    );
  }
}
