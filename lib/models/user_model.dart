class UserModel {
  final String id;
  final String? displayName;
  final String email;

  UserModel({
    required this.id,
    this.displayName,
    required this.email,
  });
}