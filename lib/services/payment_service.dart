import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../models/payment_method.dart';
import '../models/transaction.dart';
import '../models/order.dart';
import '../providers/mock_providers.dart';

class PaymentService extends ChangeNotifier {
    final Ref ref;
    bool _isProcessing = false;
    String? _errorMessage;

    PaymentService(this.ref);

    bool get isProcessing => _isProcessing;
    String? get errorMessage => _errorMessage;

    /// Process a payment for an order
    Future<bool> processPayment({
        required String orderId,
        required double amount,
        required PaymentMethodType paymentMethodType,
        String? paymentMethodId,
    }) async {
        _isProcessing = true;
        _errorMessage = null;
        notifyListeners();

        try {
            // Simulate network delay
            await Future.delayed(const Duration(seconds: 2));

            // Simulate payment processing
            final success = math.Random().nextDouble() > 0.1; // 90% success rate
            
            if (!success) {
                throw Exception('Payment failed. Please try again.');
            }

            // Create a transaction record
            final transaction = Transaction(
                id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
                orderId: orderId,
                type: TransactionType.payment,
                status: TransactionStatus.completed,
                amount: amount,
                timestamp: DateTime.now(),
                paymentMethodType: paymentMethodType,
                paymentId: 'pi_${math.Random().nextInt(1000000)}',
            );

            // In a real app, we would save this transaction to a database
            // For now, we'll just print it
            debugPrint('Payment processed: ${transaction.id}');
            
            _isProcessing = false;
            notifyListeners();
            return true;
        } catch (e) {
            _errorMessage = e.toString();
            _isProcessing = false;
            notifyListeners();
            return false;
        }
    }

    /// Process a refund for an order
    Future<bool> processRefund({
        required String orderId,
        required double amount,
        required String transactionId,
        String? reason,
    }) async {
        _isProcessing = true;
        _errorMessage = null;
        notifyListeners();

        try {
            // Simulate network delay
            await Future.delayed(const Duration(seconds: 2));

            // Simulate refund processing
            final success = math.Random().nextDouble() > 0.05; // 95% success rate
            
            if (!success) {
                throw Exception('Refund failed. Please try again.');
            }

            // Create a refund transaction record
            final refundTransaction = Transaction(
                id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
                orderId: orderId,
                type: TransactionType.refund,
                status: TransactionStatus.completed,
                amount: amount,
                timestamp: DateTime.now(),
                paymentMethodType: PaymentMethodType.stripe, // Assuming refund goes back to original payment method
                paymentId: 'ref_${math.Random().nextInt(1000000)}',
                refundReason: reason,
            );

            // In a real app, we would save this transaction to a database
            // For now, we'll just print it
            debugPrint('Refund processed: ${refundTransaction.id}');
            
            _isProcessing = false;
            notifyListeners();
            return true;
        } catch (e) {
            _errorMessage = e.toString();
            _isProcessing = false;
            notifyListeners();
            return false;
        }
    }

    /// Add funds to wallet
    Future<bool> addFundsToWallet({
        required double amount,
        required PaymentMethodType paymentMethodType,
        String? paymentMethodId,
    }) async {
        _isProcessing = true;
        _errorMessage = null;
        notifyListeners();

        try {
            // Simulate network delay
            await Future.delayed(const Duration(seconds: 2));

            // Simulate payment processing
            final success = math.Random().nextDouble() > 0.1; // 90% success rate
            
            if (!success) {
                throw Exception('Adding funds failed. Please try again.');
            }

            // Create a wallet deposit transaction record
            final transaction = Transaction(
                id: 'wdp_${DateTime.now().millisecondsSinceEpoch}',
                orderId: '', // No order associated with wallet deposit
                type: TransactionType.walletDeposit,
                status: TransactionStatus.completed,
                amount: amount,
                timestamp: DateTime.now(),
                paymentMethodType: paymentMethodType,
                paymentId: 'pi_${math.Random().nextInt(1000000)}',
            );

            // In a real app, we would save this transaction to a database
            // For now, we'll just print it
            debugPrint('Wallet deposit processed: ${transaction.id}');
            
            _isProcessing = false;
            notifyListeners();
            return true;
        } catch (e) {
            _errorMessage = e.toString();
            _isProcessing = false;
            notifyListeners();
            return false;
        }
    }

    /// Pay for an order using wallet balance
    Future<bool> payWithWallet({
        required String orderId,
        required double amount,
    }) async {
        _isProcessing = true;
        _errorMessage = null;
        notifyListeners();

        try {
            // Get current wallet balance
            final wallet = ref.read(walletProvider);
            
            if (wallet.balance < amount) {
                throw Exception('Insufficient wallet balance');
            }

            // Simulate network delay
            await Future.delayed(const Duration(seconds: 1));

            // Create a wallet payment transaction record
            final transaction = Transaction(
                id: 'wpay_${DateTime.now().millisecondsSinceEpoch}',
                orderId: orderId,
                type: TransactionType.payment,
                status: TransactionStatus.completed,
                amount: amount,
                timestamp: DateTime.now(),
                paymentMethodType: PaymentMethodType.wallet,
            );

            // In a real app, we would save this transaction to a database
            // For now, we'll just print it
            debugPrint('Wallet payment processed: ${transaction.id}');
            
            _isProcessing = false;
            notifyListeners();
            return true;
        } catch (e) {
            _errorMessage = e.toString();
            _isProcessing = false;
            notifyListeners();
            return false;
        }
    }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
    return PaymentService(ref);
});
