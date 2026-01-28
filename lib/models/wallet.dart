import 'transaction.dart';

class Wallet {
    final String userId;
    final double balance;
    final List<Transaction> transactions;
    final DateTime lastUpdated;

    const Wallet({
        required this.userId,
        required this.balance,
        required this.transactions,
        required this.lastUpdated,
    });

    Wallet copyWith({
        String? userId,
        double? balance,
        List<Transaction>? transactions,
        DateTime? lastUpdated,
    }) {
        return Wallet(
            userId: userId ?? this.userId,
            balance: balance ?? this.balance,
            transactions: transactions ?? this.transactions,
            lastUpdated: lastUpdated ?? this.lastUpdated,
        );
    }

    /// Returns a list of transactions sorted by timestamp (newest first)
    List<Transaction> get sortedTransactions {
        final sorted = List<Transaction>.from(transactions);
        sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return sorted;
    }

    /// Returns the total amount deposited into the wallet
    double get totalDeposited {
        return transactions
            .where((t) => t.type == TransactionType.walletDeposit && 
                          t.status == TransactionStatus.completed)
            .fold(0.0, (sum, t) => sum + t.amount);
    }

    /// Returns the total amount spent from the wallet
    double get totalSpent {
        return transactions
            .where((t) => (t.type == TransactionType.payment || 
                          t.type == TransactionType.walletWithdrawal) && 
                          t.status == TransactionStatus.completed)
            .fold(0.0, (sum, t) => sum + t.amount);
    }

    /// Returns the total amount refunded to the wallet
    double get totalRefunded {
        return transactions
            .where((t) => t.type == TransactionType.refund && 
                          t.status == TransactionStatus.completed)
            .fold(0.0, (sum, t) => sum + t.amount);
    }
}