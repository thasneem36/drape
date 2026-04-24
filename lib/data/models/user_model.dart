class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String address;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl = '',
    this.address = '',
  });
}
