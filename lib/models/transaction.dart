import 'package:flutter/material.dart';
import 'payment_method.dart';

enum TransactionType {
    payment,
    refund,
    walletDeposit,
    walletWithdrawal,
}

enum TransactionStatus {
    pending,
    completed,
    failed,
    refunded,
    partiallyRefunded,
}

class Transaction {
    final String id;
    final String orderId;
    final TransactionType type;
    final TransactionStatus status;
    final double amount;
    final DateTime timestamp;
    final PaymentMethodType paymentMethodType;
    final String? paymentId; // External payment reference
    final String? refundReason;

    const Transaction({
        required this.id,
        required this.orderId,
        required this.type,
        required this.status,
        required this.amount,
        required this.timestamp,
        required this.paymentMethodType,
        this.paymentId,
        this.refundReason,
    });

    String get statusText {
        switch (status) {
            case TransactionStatus.pending:
                return 'Pending';
            case TransactionStatus.completed:
                return 'Completed';
            case TransactionStatus.failed:
                return 'Failed';
            case TransactionStatus.refunded:
                return 'Refunded';
            case TransactionStatus.partiallyRefunded:
                return 'Partially Refunded';
        }
    }

    Color get statusColor {
        switch (status) {
            case TransactionStatus.pending:
                return Colors.orange;
            case TransactionStatus.completed:
                return Colors.green;
            case TransactionStatus.failed:
                return Colors.red;
            case TransactionStatus.refunded:
                return Colors.blue;
            case TransactionStatus.partiallyRefunded:
                return Colors.lightBlue;
        }
    }

    String get typeText {
        switch (type) {
            case TransactionType.payment:
                return 'Payment';
            case TransactionType.refund:
                return 'Refund';
            case TransactionType.walletDeposit:
                return 'Wallet Deposit';
            case TransactionType.walletWithdrawal:
                return 'Wallet Withdrawal';
        }
    }

    IconData get typeIcon {
        switch (type) {
            case TransactionType.payment:
                return Icons.payment;
            case TransactionType.refund:
                return Icons.replay;
            case TransactionType.walletDeposit:
                return Icons.add_card;
            case TransactionType.walletWithdrawal:
                return Icons.money_off;
        }
    }

    bool get isRefundable {
        return type == TransactionType.payment && 
               status == TransactionStatus.completed &&
               paymentMethodType != PaymentMethodType.cash;
    }
}