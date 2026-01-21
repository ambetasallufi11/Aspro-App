class UserProfile {
  final String name;
  final String email;
  final String phone;
  final List<String> addresses;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.addresses,
  });
}
