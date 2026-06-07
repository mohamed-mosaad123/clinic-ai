class UserModel {
  final String id;
  final String fullName;
  final String email;
  final List<String> roles;
  final String? token;
  final String? refreshToken;
  final DateTime? expiration;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roles,
    this.token,
    this.refreshToken,
    this.expiration,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['userName'] ?? '',
      email: json['email'] ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      token: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
      expiration: json['expiration'] != null ? DateTime.tryParse(json['expiration']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'roles': roles,
    'token': token,
    'refreshToken': refreshToken,
    'expiration': expiration?.toIso8601String(),
  };

  String get primaryRole => roles.isNotEmpty ? roles.first : 'patient';
  String get role => primaryRole;
}
