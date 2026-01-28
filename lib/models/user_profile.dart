class UserProfile {
  final String name;
  final String email;
  final String phone;
  final List<String> addresses;
  final double walletBalance;
  final List<String>? savedPaymentMethods;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.addresses,
    this.walletBalance = 0.0,
    this.savedPaymentMethods,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    List<String>? addresses,
    double? walletBalance,
    List<String>? savedPaymentMethods,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addresses: addresses ?? this.addresses,
      walletBalance: walletBalance ?? this.walletBalance,
      savedPaymentMethods: savedPaymentMethods ?? this.savedPaymentMethods,
    );
  }

  bool get hasWalletBalance => walletBalance > 0;
  
  String get formattedWalletBalance => '\$${walletBalance.toStringAsFixed(2)}';
}
