enum PaymentMethodType {
    stripe,
    paypal,
    cash,
    wallet,
}

class PaymentMethod {
    final String id;
    final PaymentMethodType type;
    final String? cardLastFour;
    final String? cardBrand;
    final String? email; // For PayPal
    final bool isDefault;

    const PaymentMethod({
        required this.id,
        required this.type,
        this.cardLastFour,
        this.cardBrand,
        this.email,
        this.isDefault = false,
    });

    String get displayName {
        switch (type) {
            case PaymentMethodType.stripe:
                return 'Credit Card (${cardBrand ?? 'Card'} •••• ${cardLastFour ?? '****'})';
            case PaymentMethodType.paypal:
                return 'PayPal${email != null ? ' ($email)' : ''}';
            case PaymentMethodType.cash:
                return 'Cash on Delivery';
            case PaymentMethodType.wallet:
                return 'Wallet Balance';
        }
    }

    String get iconName {
        switch (type) {
            case PaymentMethodType.stripe:
                return 'credit_card';
            case PaymentMethodType.paypal:
                return 'account_balance';
            case PaymentMethodType.cash:
                return 'payments';
            case PaymentMethodType.wallet:
                return 'account_balance_wallet';
        }
    }
}