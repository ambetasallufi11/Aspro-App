import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_data.dart';
import '../models/promo_code.dart';

// Provider for all available promo codes
final promoCodesProvider = Provider<List<PromoCode>>((ref) => MockData.promoCodes);

// State for the currently applied promo code
class AppliedPromoCodeState {
  final PromoCode? promoCode;
  final bool isValid;
  final String? errorMessage;

  const AppliedPromoCodeState({
    this.promoCode,
    this.isValid = false,
    this.errorMessage,
  });

  AppliedPromoCodeState copyWith({
    PromoCode? promoCode,
    bool? isValid,
    String? errorMessage,
  }) {
    return AppliedPromoCodeState(
      promoCode: promoCode ?? this.promoCode,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
    );
  }

  // Calculate discount amount based on the original price
  double calculateDiscount(double originalPrice) {
    if (promoCode == null || !isValid) return 0.0;
    return promoCode!.calculateDiscount(originalPrice);
  }

  // Calculate final price after discount
  double calculateFinalPrice(double originalPrice) {
    if (promoCode == null || !isValid) return originalPrice;
    final discount = calculateDiscount(originalPrice);
    return originalPrice - discount;
  }
}

// Notifier for the applied promo code state
class AppliedPromoCodeNotifier extends Notifier<AppliedPromoCodeState> {
  @override
  AppliedPromoCodeState build() {
    return const AppliedPromoCodeState();
  }

  void applyPromoCode(String code) {
    // Reset state
    state = const AppliedPromoCodeState();

    // Get available promo codes
    final availablePromoCodes = ref.read(promoCodesProvider);
    
    // In a real app, you would determine if the user is a recurring customer
    // based on their order history or user profile
    const isRecurringCustomer = false;

    try {
      // Find promo code
      final normalizedCode = code.trim().toUpperCase();
      final promoCode = availablePromoCodes.firstWhere(
        (promo) => promo.code.toUpperCase() == normalizedCode,
        orElse: () => throw Exception('Promo code not found'),
      );

      // Check if promo code exists
      if (promoCode.id.isEmpty) {
        state = AppliedPromoCodeState(
          errorMessage: 'Invalid promo code',
        );
        return;
      }

      // Check if promo code is expired
      if (promoCode.isExpired) {
        state = AppliedPromoCodeState(
          promoCode: promoCode,
          errorMessage: 'This promo code has expired',
        );
        return;
      }

      // Check if usage limit is reached
      if (promoCode.isUsageLimitReached) {
        state = AppliedPromoCodeState(
          promoCode: promoCode,
          errorMessage: 'This promo code has reached its usage limit',
        );
        return;
      }

      // Check if customer is eligible for recurring customer promo
      if (promoCode.isForRecurringCustomers && !isRecurringCustomer) {
        state = AppliedPromoCodeState(
          promoCode: promoCode,
          errorMessage: 'This promo code is only for recurring customers',
        );
        return;
      }

      // Promo code is valid
      state = AppliedPromoCodeState(
        promoCode: promoCode,
        isValid: true,
      );
    } catch (e) {
      state = AppliedPromoCodeState(
        errorMessage: 'Invalid promo code',
      );
    }
  }

  void clearPromoCode() {
    state = const AppliedPromoCodeState();
  }
}

// Provider for the applied promo code state
final appliedPromoCodeProvider = NotifierProvider<AppliedPromoCodeNotifier, AppliedPromoCodeState>(
  () => AppliedPromoCodeNotifier(),
);