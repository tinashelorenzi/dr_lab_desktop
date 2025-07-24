class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String userType;
  final String userTypeLabel;
  final bool accountIsSet;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? dateHired;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.userType,
    required this.userTypeLabel,
    required this.accountIsSet,
    required this.isActive,
    this.lastLoginAt,
    this.dateHired,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get initials
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Check if user needs account setup
  bool get needsAccountSetup => !accountIsSet;

  /// Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      userType: json['user_type'] as String,
      userTypeLabel: json['user_type_label'] as String,
      accountIsSet: json['account_is_set'] as bool,
      isActive: json['is_active'] as bool,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      dateHired: json['date_hired'] != null 
          ? DateTime.parse(json['date_hired'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'user_type': userType,
      'user_type_label': userTypeLabel,
      'account_is_set': accountIsSet,
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'date_hired': dateHired?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? userType,
    String? userTypeLabel,
    bool? accountIsSet,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? dateHired,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      userTypeLabel: userTypeLabel ?? this.userTypeLabel,
      accountIsSet: accountIsSet ?? this.accountIsSet,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      dateHired: dateHired ?? this.dateHired,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, fullName: $fullName, email: $email, userType: $userType, accountIsSet: $accountIsSet)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}