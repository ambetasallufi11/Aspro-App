enum PromoCodeType {
  percentage,
  fixedAmount,
}

class PromoCode {
  final String id;
  final String code;
  final String merchantId;
  final PromoCodeType type;
  final double value; // Percentage or fixed amount
  final String description;
  final DateTime? expirationDate;
  final int? usageLimit;
  final int usageCount;
  final bool isForRecurringCustomers;

  const PromoCode({
    required this.id,
    required this.code,
    required this.merchantId,
    required this.type,
    required this.value,
    required this.description,
    this.expirationDate,
    this.usageLimit,
    this.usageCount = 0,
    this.isForRecurringCustomers = false,
  });

  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  bool get isUsageLimitReached {
    if (usageLimit == null) return false;
    return usageCount >= usageLimit!;
  }

  bool get isValid {
    return !isExpired && !isUsageLimitReached;
  }

  double calculateDiscount(double originalPrice) {
    if (type == PromoCodeType.percentage) {
      return originalPrice * (value / 100);
    } else {
      return value > originalPrice ? originalPrice : value;
    }
  }

  PromoCode copyWith({
    String? id,
    String? code,
    String? merchantId,
    PromoCodeType? type,
    double? value,
    String? description,
    DateTime? expirationDate,
    int? usageLimit,
    int? usageCount,
    bool? isForRecurringCustomers,
  }) {
    return PromoCode(
      id: id ?? this.id,
      code: code ?? this.code,
      merchantId: merchantId ?? this.merchantId,
      type: type ?? this.type,
      value: value ?? this.value,
      description: description ?? this.description,
      expirationDate: expirationDate ?? this.expirationDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      isForRecurringCustomers: isForRecurringCustomers ?? this.isForRecurringCustomers,
    );
  }
}