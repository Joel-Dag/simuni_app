// lib/app_state.dart
import 'package:flutter/material.dart';
import 'transaction_model.dart';

class AppState extends ChangeNotifier {
  // Pre-seeded base records matching your design metrics
  final List<TransactionModel> _transactions = [
    TransactionModel(
      referenceNumber: "FT26185GHYT2",
      amount: 4500.00,
      rawSender: "CBE",
      accountLabel: "1000****3866",
      typeLabel: "RECEIVED",
      transactionDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TransactionModel(
      referenceNumber: "TXN983210492",
      amount: -1250.50,
      rawSender: "Telebirr",
      accountLabel: "0944****21",
      typeLabel: "DEBITED",
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  // Structural dynamic mathematics for your fintech widgets
  double get totalNetWorth => 162450.00 + totalNetChange;
  double get totalNetChange => _transactions.fold(0.0, (sum, item) => sum + item.amount);
  
  double get cbeBalance => 98500.00 + _transactions.where((t) => t.rawSender == "CBE").fold(0.0, (sum, item) => sum + item.amount);
  double get telebirrBalance => 18000.00 + _transactions.where((t) => t.rawSender == "Telebirr").fold(0.0, (sum, item) => sum + item.amount);
  double get dashenBalance => 15000.00; // Static baseline sample representation

  double get todayIncome => _transactions.where((t) => t.isIncome && _isToday(t.transactionDate)).fold(0.0, (sum, item) => sum + item.amount);
  double get todayExpense => _transactions.where((t) => !t.isIncome && _isToday(t.transactionDate)).fold(0.0, (sum, item) => sum + item.amount).abs();

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  // Live callback route for background SMS broadcast receivers
  void addParsedTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    notifyListeners(); 
  }
}