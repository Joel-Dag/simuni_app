// lib/app_state.dart
import 'package:flutter/material.dart';
import 'transaction_model.dart';

class UserProfile {
  final String id;
  String name;
  UserProfile({required this.id, required this.name});
}

class AppState extends ChangeNotifier {
  bool _isFirstTimeUser = true;
  bool _isDarkMode = true;
  String _currentFont = "Inter";
  double _fontSize = 14.0;
  
  String _apiKey = "";
  String _aiProvider = "Gemini";

  // Notification Flags
  bool txAlerts = true;
  bool budgetAlerts = true;

  // Profiles Matrix Handling
  final List<UserProfile> _profiles = [];
  int _activeProfileIndex = 0;

  // Pre-seeded base records matching your design metrics
  final List<TransactionModel> _transactions = [
    TransactionModel(
      referenceNumber: "FT26185GHYT2",
      amount: 4500.00,
      rawSender: "CBE",
      accountLabel: "1000****3866",
      typeLabel: "RECEIVED",
      depositorName: "Incoming Transfer (1000****3866)",
      transactionDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TransactionModel(
      referenceNumber: "TXN983210492",
      amount: -1250.50,
      rawSender: "Telebirr",
      accountLabel: "0944****21",
      typeLabel: "DEBITED",
      depositorName: "Outgoing Payment (0944****21)",
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  // Structural dynamic mathematics for your fintech widgets
  double get totalNetWorth => 162450.00 + totalNetChange;
  double get totalNetChange => _transactions.fold(0.0, (sum, item) => sum + item.amount);
  
  double get cbeBalance => 98500.00 + _transactions.where((t) => t.rawSender == "CBE").fold(0.0, (sum, item) => sum + item.amount);
  double get telebirrBalance => 18000.00 + _transactions.where((t) => t.rawSender == "Telebirr").fold(0.0, (sum, item) => sum + item.amount);
  double get dashenBalance => 15000.00;

  double get todayIncome => _transactions.where((t) => t.isIncome && _isToday(t.transactionDate)).fold(0.0, (sum, item) => sum + item.amount);
  double get todayExpense => _transactions.where((t) => !t.isIncome && _isToday(t.transactionDate)).fold(0.0, (sum, item) => sum + item.amount).abs();

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  bool get isFirstTimeUser => _isFirstTimeUser;
  bool get isDarkMode => _isDarkMode;
  String get currentFont => _currentFont;
  double get fontSize => _fontSize;
  String get apiKey => _apiKey;
  String get aiProvider => _aiProvider;
  List<UserProfile> get profiles => _profiles;
  UserProfile get activeProfile => _profiles.isNotEmpty ? _profiles[_activeProfileIndex] : UserProfile(id: "0", name: "Guest");

  void completeOnboarding() {
    _isFirstTimeUser = false;
    notifyListeners();
  }

  void updateApiKey(String key, String provider) {
    _apiKey = key;
    _aiProvider = provider;
    notifyListeners();
  }

  void toggleTheme(bool dark) {
    _isDarkMode = dark;
    notifyListeners();
  }

  void addParsedTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  void updateTypography(String font, double size) {
    _currentFont = font;
    _fontSize = size;
    notifyListeners();
  }

  void toggleNotificationSettings(String type, bool value) {
    if (type == "tx") txAlerts = value;
    if (type == "budget") budgetAlerts = value;
    notifyListeners();
  }

  void createNewProfile(String name) {
    final newProf = UserProfile(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name);
    _profiles.add(newProf);
    _activeProfileIndex = _profiles.length - 1;
    notifyListeners();
  }

  void switchProfile(int index) {
    if (index >= 0 && index < _profiles.length) {
      _activeProfileIndex = index;
      notifyListeners();
    }
  }
}