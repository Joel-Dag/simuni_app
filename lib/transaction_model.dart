// lib/transaction_model.dart

class TransactionModel {
  final String referenceNumber;
  final String depositorName;
  final double amount;
  final DateTime transactionDate;
  final String rawSmsBody;
  final bool isMatchedToDebt;

  TransactionModel({
    required this.referenceNumber,
    required this.depositorName,
    required this.amount,
    required this.transactionDate,
    required this.rawSmsBody,
    this.isMatchedToDebt = false,
  });

  // Convert a Database row back into a usable Dart object
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      referenceNumber: map['reference_number'] as String,
      depositorName: map['depositor_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      rawSmsBody: map['raw_sms_body'] as String,
      isMatchedToDebt: map['is_matched_to_debt'] == 1,
    );
  }

  // Convert an object state into a structured Map for SQL execution
  Map<String, dynamic> toMap() {
    return {
      'reference_number': referenceNumber,
      'depositor_name': depositorName,
      'amount': amount,
      'transaction_date': transactionDate.toIso8601String(),
      'raw_sms_body': rawSmsBody,
      'is_matched_to_debt': isMatchedToDebt ? 1 : 0,
    };
  }
}