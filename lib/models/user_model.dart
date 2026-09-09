class UserModel {
  final String id;
  final String? name;
  final String phone;
  final String? role;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    this.name,
    required this.phone,
    this.role,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String?,
      phone: (json['phone'] ?? '').toString(),
      role: json['role'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
