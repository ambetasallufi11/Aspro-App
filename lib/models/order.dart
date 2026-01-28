enum OrderStatus {
  pending,
  pickedUp,
  washing,
  ready,
  delivered,
  cancelled,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
  partiallyRefunded,
}

class Order {
  final String id;
  final String laundryName;
  final OrderStatus status;
  final double total;
  final DateTime createdAt;
  final PaymentStatus paymentStatus;
  final String? paymentMethodId;
  final String? paymentId; // External payment reference
  final DateTime? paidAt;
  final bool isWalletPayment;

  const Order({
    required this.id,
    required this.laundryName,
    required this.status,
    required this.total,
    required this.createdAt,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethodId,
    this.paymentId,
    this.paidAt,
    this.isWalletPayment = false,
  });

  bool get isPaid => paymentStatus == PaymentStatus.paid;
  
  bool get isRefundable => 
      isPaid && 
      (status == OrderStatus.pending || status == OrderStatus.pickedUp) &&
      (paymentMethodId != null || isWalletPayment);
  
  bool get isDelivered => status == OrderStatus.delivered;
  
  bool get isCancelled => status == OrderStatus.cancelled;
  
  String get paymentStatusText {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }
}
