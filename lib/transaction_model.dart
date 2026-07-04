// lib/transaction_model.dart
class TransactionModel {
  final String referenceNumber;
  final double amount;
  final String rawSender;      // e.g., "CBE" or "Telebirr"
  final String accountLabel;   // e.g., "1000****3866"
  final String typeLabel;      // e.g., "RECEIVED", "DEBITED"
  final String depositorName;  // e.g., "Incoming Transfer" or "Outgoing Payment"
  final DateTime transactionDate;

  TransactionModel({
    required this.referenceNumber,
    required this.amount,
    required this.rawSender,
    required this.accountLabel,
    required this.typeLabel,
    required this.depositorName,
    required this.transactionDate,
  });

  // Helper method to quickly determine cashflow direction
  bool get isIncome => amount > 0;

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'referenceNumber': referenceNumber,
      'amount': amount,
      'rawSender': rawSender,
      'accountLabel': accountLabel,
      'typeLabel': typeLabel,
      'depositorName': depositorName,
      'transactionDate': transactionDate.toIso8601String(),
    };
  }

  // Create from Map (database retrieval)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      referenceNumber: map['referenceNumber'] as String,
      amount: (map['amount'] as num).toDouble(),
      rawSender: map['rawSender'] as String,
      accountLabel: map['accountLabel'] as String,
      typeLabel: map['typeLabel'] as String,
      depositorName: map['depositorName'] as String,
      transactionDate: DateTime.parse(map['transactionDate'] as String),
    );
  }
}