class User {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? phoneCountryCode;
  final String? locale;
  final bool? isActive;
  final List<String>? roles;
  final String? createdAt;
  final String? accountType;
  final String? companyName;
  final String? avatarUrl;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.phoneCountryCode,
    this.locale,
    this.isActive,
    this.roles,
    this.createdAt,
    this.accountType,
    this.companyName,
    this.avatarUrl,
  });

  bool get isCompany => accountType == 'company' || (companyName != null && companyName!.isNotEmpty);

  String get initials {
    if (name == null || name!.isEmpty) return 'PW';
    final parts = name!.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      phoneCountryCode: json['phone_country_code'],
      locale: json['locale'],
      isActive: json['is_active'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
      createdAt: json['created_at'],
      accountType: json['account_type'] ?? json['company_type'],
      companyName: json['company_name'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'phone_country_code': phoneCountryCode,
      'locale': locale,
      'is_active': isActive,
      'created_at': createdAt,
      'roles': roles,
      'account_type': accountType,
      'company_name': companyName,
      'avatar_url': avatarUrl,
    };
  }
}
