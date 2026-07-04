// lib/transaction_model.dart or lib/models/transaction_model.dart
class TransactionModel {
  final String referenceNumber;
  final double amount;
  final double resultingBalance; 
  final String rawSender;        
  final String accountLabel;
  final String typeLabel;        
  final DateTime transactionDate;
  final String depositorName; // Added back to satisfy dashboard and Gemini parser

  TransactionModel({
    required this.referenceNumber,
    required this.amount,
    required this.resultingBalance,
    required this.rawSender,
    required this.accountLabel,
    required this.typeLabel,
    required this.transactionDate,
    required this.depositorName,
  });

  bool get isIncome => typeLabel == "RECEIVED";

  /// FIX: Added to satisfy database serialization in database_helper.dart
  Map<String, dynamic> toMap() {
    return {
      'referenceNumber': referenceNumber,
      'amount': amount,
      'resultingBalance': resultingBalance,
      'rawSender': rawSender,
      'accountLabel': accountLabel,
      'typeLabel': typeLabel,
      'transactionDate': transactionDate.toIso8601String(),
      'depositorName': depositorName,
    };
  }

  /// FIX: Added to satisfy database reconstruction in database_helper.dart
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      referenceNumber: map['referenceNumber'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      resultingBalance: (map['resultingBalance'] as num?)?.toDouble() ?? 0.0,
      rawSender: map['rawSender'] ?? '',
      accountLabel: map['accountLabel'] ?? '',
      typeLabel: map['typeLabel'] ?? '',
      transactionDate: map['transactionDate'] != null 
          ? DateTime.parse(map['transactionDate']) 
          : DateTime.now(),
      depositorName: map['depositorName'] ?? '',
    );
  }
}