class UserModel {
  final String id;
  final String? displayName;
  final String email;
  final String role;

  UserModel({
    required this.id,
    this.displayName,
    required this.email,
    required this.role,
  });
}
