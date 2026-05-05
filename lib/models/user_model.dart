class UserModel {
  final String id;
  final String name;
  final String email;
  final String? farmName;
  final String? farmId;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.farmName,
    this.farmId,
    this.role = 'usuario',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:       json['id']?.toString()       ?? '',
        name:     json['name']   as String?    ?? '',
        email:    json['email']  as String?    ?? '',
        farmName: json['farm_name'] as String?,
        farmId:   json['farm_id']?.toString(),
        role:     json['role']   as String?    ?? 'usuario',
      );

  Map<String, dynamic> toJson() => {
        'id':        id,
        'name':      name,
        'email':     email,
        'farm_name': farmName,
        'farm_id':   farmId,
        'role':      role,
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? farmName,
    String? farmId,
    String? role,
  }) =>
      UserModel(
        id:       id,
        name:     name      ?? this.name,
        email:    email     ?? this.email,
        farmName: farmName  ?? this.farmName,
        farmId:   farmId    ?? this.farmId,
        role:     role      ?? this.role,
      );
}
