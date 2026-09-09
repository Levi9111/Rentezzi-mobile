class ReceiptModel {
  final String id;
  final String tenantName;
  final String? tenantPhone;
  final String? propertyId;
  final String? propertyName;
  final String? unitId;
  final String? unitName;
  final String propertyAddress;
  final num rentAmount;
  final num? waterBill;
  final num? gasBill;
  final num? otherBills;
  final num totalAmount;
  final String monthYear;
  final String paymentDate;
  final String paymentMethod; // 'cash' | 'bank_transfer' | 'mobile_banking'
  final String? landlordName;
  final String? landlordPhone;
  final String? notes;
  final String? pdfUrl;
  final String receiptLang; // 'en' | 'bn'
  final DateTime createdAt;

  ReceiptModel({
    required this.id,
    required this.tenantName,
    this.tenantPhone,
    this.propertyId,
    this.propertyName,
    this.unitId,
    this.unitName,
    required this.propertyAddress,
    required this.rentAmount,
    this.waterBill,
    this.gasBill,
    this.otherBills,
    required this.totalAmount,
    required this.monthYear,
    required this.paymentDate,
    required this.paymentMethod,
    this.landlordName,
    this.landlordPhone,
    this.notes,
    this.pdfUrl,
    this.receiptLang = 'en',
    required this.createdAt,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    num rent = json['rentAmount'] ?? 0;
    num water = json['waterBill'] ?? 0;
    num gas = json['gasBill'] ?? 0;
    num other = json['otherBills'] ?? 0;
    num total = json['totalAmount'] ?? (rent + water + gas + other);

    return ReceiptModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      tenantName: (json['tenantName'] ?? '').toString(),
      tenantPhone: json['tenantPhone']?.toString(),
      propertyId: json['propertyId']?.toString(),
      propertyName: json['propertyName']?.toString(),
      unitId: json['unitId']?.toString(),
      unitName: json['unitName']?.toString(),
      propertyAddress: (json['propertyAddress'] ?? '').toString(),
      rentAmount: rent,
      waterBill: json['waterBill'],
      gasBill: json['gasBill'],
      otherBills: json['otherBills'],
      totalAmount: total,
      monthYear: (json['monthYear'] ?? '').toString(),
      paymentDate: (json['paymentDate'] ?? '').toString(),
      paymentMethod: (json['paymentMethod'] ?? 'cash').toString(),
      landlordName: json['landlordName']?.toString(),
      landlordPhone: json['landlordPhone']?.toString(),
      notes: json['notes']?.toString(),
      pdfUrl: json['pdfUrl']?.toString(),
      receiptLang: (json['receiptLang'] ?? 'en').toString(),
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'unitId': unitId,
      'unitName': unitName,
      'propertyAddress': propertyAddress,
      'rentAmount': rentAmount,
      'waterBill': waterBill,
      'gasBill': gasBill,
      'otherBills': otherBills,
      'totalAmount': totalAmount,
      'monthYear': monthYear,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'landlordName': landlordName,
      'landlordPhone': landlordPhone,
      'notes': notes,
      'pdfUrl': pdfUrl,
      'receiptLang': receiptLang,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
