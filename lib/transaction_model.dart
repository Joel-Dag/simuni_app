// lib/transaction_model.dart
class TransactionModel {
  final int? id;
  final String referenceNumber;
  final double amount;
  final String depositorName;
  final DateTime transactionDate;

  TransactionModel({
    this.id,
    required this.referenceNumber,
    required this.amount,
    required this.depositorName,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'referenceNumber': referenceNumber,
      'amount': amount,
      'depositorName': depositorName,
      'transactionDate': transactionDate.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      referenceNumber: map['referenceNumber'],
      amount: map['amount'],
      depositorName: map['depositorName'],
      transactionDate: DateTime.parse(map['transactionDate']),
    );
  }
}