// lib/app_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'transaction_model.dart'; // Direct relative import since all files are in lib/

class UserProfile {
  final String id;
  String name;
  UserProfile({required this.id, required this.name});
}

class AppState extends ChangeNotifier {
  bool _isFirstTimeUser = true;
  bool _isDarkMode = true;
  String _currentFont = "monospace"; 
  double _fontSize = 14.0;
  String _apiKey = "";
  
  // Real live transaction storage array - NO MORE SAMPLE SEEDS!
  List<TransactionModel> _transactions = [];

  // Notification / Alert Flags
  bool txAlerts = true;
  bool budgetAlerts = true;

  // Profiles Matrix Handling
  final List<UserProfile> _profiles = [];
  int _activeProfileIndex = 0;

  // Core Getters
  bool get isFirstTimeUser => _isFirstTimeUser;
  bool get isDarkMode => _isDarkMode;
  String get currentFont => _currentFont;
  double get fontSize => _fontSize;
  String get apiKey => _apiKey;
  List<TransactionModel> get transactions => _transactions;
  List<UserProfile> get profiles => _profiles;
  UserProfile get activeProfile => _profiles.isNotEmpty ? _profiles[_activeProfileIndex] : UserProfile(id: "0", name: "Guest Workspace");

  // Real-Time Derived Balances (Using native safe iterable properties)
  double get cbeBalance {
    final cbeTx = _transactions.where((t) => t.rawSender == "CBE");
    return cbeTx.isNotEmpty ? cbeTx.first.resultingBalance : 0.0;
  }

  double get telebirrBalance {
    final telebirrTx = _transactions.where((t) => t.rawSender == "Telebirr");
    return telebirrTx.isNotEmpty ? telebirrTx.first.resultingBalance : 0.0;
  }

  double get dashenBalance {
    final dashenTx = _transactions.where((t) => t.rawSender == "Dashen");
    return dashenTx.isNotEmpty ? dashenTx.first.resultingBalance : 0.0;
  }

  double get todayIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.isIncome &&
            t.transactionDate.year == now.year &&
            t.transactionDate.month == now.month &&
            t.transactionDate.day == now.day)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  /// Calculates total money spent today across all synced channels
  double get todayExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            !t.isIncome &&
            t.transactionDate.year == now.year &&
            t.transactionDate.month == now.month &&
            t.transactionDate.day == now.day)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  // Combined physical real-world wealth sum
  double get totalNetWorth => cbeBalance + telebirrBalance + dashenBalance;

  /// THE CORE SYNC METHOD BEING CALLED BY MAIN.DART
  void syncSmsData(List<SmsMessage> rawMessages) {
    // Import the parser dynamically to prevent initialization loop issues
    // loops if imported globally in some flat file layouts
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    List<TransactionModel> syncBuffer = [];

    // Let's manually parse right inside the controller line to stay 100% bulletproof
    for (var message in rawMessages) {
      if (message.date == null || message.date!.isBefore(ninetyDaysAgo)) continue;
      
      final body = message.body ?? "";
      final sender = (message.sender ?? "").toUpperCase();
      TransactionModel? parsed;

      try {
        if (sender.contains("CBE") || body.contains("Commercial Bank")) {
          final balReg = RegExp(r'(?:balance is|bal:?)\s*(?:ETB)?\s*([\d,]+\.\d{2})', caseSensitive: false);
          final amtReg = RegExp(r'(?:ETB|debited|credited|received)\s*([\d,]+\.\d{2})');
          final refReg = RegExp(r'(?:Ref|Txn|ID):\s*([A-Z0-9]+)', caseSensitive: false);
          final accReg = RegExp(r'(?:account|acc\.)\s*([0-9\*]+)');

          final balMatch = balReg.firstMatch(body);
          if (balMatch != null) {
            final double balance = double.parse(balMatch.group(1)!.replaceAll(',', ''));
            final amtMatch = amtReg.firstMatch(body);
            final double amount = amtMatch != null ? double.parse(amtMatch.group(1)!.replaceAll(',', '')) : 0.0;
            final refMatch = refReg.firstMatch(body);
            final accMatch = accReg.firstMatch(body);
            final bool isDebit = body.toLowerCase().contains("debited") || body.toLowerCase().contains("paid");

            parsed = TransactionModel(
              referenceNumber: refMatch != null ? refMatch.group(1)! : "REF-${message.date!.millisecondsSinceEpoch}",
              amount: isDebit ? -amount : amount,
              resultingBalance: balance,
              rawSender: "CBE",
              accountLabel: accMatch != null ? accMatch.group(1)! : "CBE-Acc",
              typeLabel: isDebit ? "DEBITED" : "RECEIVED",
              transactionDate: message.date!,
              depositorName: accMatch != null ? accMatch.group(1)! : "CBE-Acc",
            );
          }
        } else if (sender.contains("TELEBIRR") || sender.contains("127")) {
          final balReg = RegExp(r'(?:balance is|bal:?)\s*ETB\s*([\d,]+\.\d{2})', caseSensitive: false);
          final amtReg = RegExp(r'(?:received|transferred|paid)\s*ETB\s*([\d,]+\.\d{2})', caseSensitive: false);
          final refReg = RegExp(r'(?:ID|Txn):\s*([0-9A-Za-z]+)', caseSensitive: false);

          final balMatch = balReg.firstMatch(body);
          if (balMatch != null) {
            final double balance = double.parse(balMatch.group(1)!.replaceAll(',', ''));
            final amtMatch = amtReg.firstMatch(body);
            final double amount = amtMatch != null ? double.parse(amtMatch.group(1)!.replaceAll(',', '')) : 0.0;
            final refMatch = refReg.firstMatch(body);
            final bool isDebit = body.toLowerCase().contains("paid") || body.toLowerCase().contains("transferred to");

            parsed = TransactionModel(
              referenceNumber: refMatch != null ? refMatch.group(1)! : "TLB-${message.date!.millisecondsSinceEpoch}",
              amount: isDebit ? -amount : amount,
              resultingBalance: balance,
              rawSender: "Telebirr",
              accountLabel: "Mobile Wallet",
              typeLabel: isDebit ? "DEBITED" : "RECEIVED",
              transactionDate: message.date!,
              depositorName: "Telebirr User",
            );
          }
        } else if (sender.contains("DASHEN") || sender.contains("AMOLE")) {
          final balReg = RegExp(r'(?:balance is|bal is|bal:?)\s*(?:ETB)?\s*([\d,]+\.\d{2})', caseSensitive: false);
          final amtReg = RegExp(r'(?:ETB|debited|credited)\s*([\d,]+\.\d{2})');
          final refReg = RegExp(r'(?:Ref|Txn|ID):\s*([A-Za-z0-9]+)', caseSensitive: false);

          final balMatch = balReg.firstMatch(body);
          if (balMatch != null) {
            final double balance = double.parse(balMatch.group(1)!.replaceAll(',', ''));
            final amtMatch = amtReg.firstMatch(body);
            final double amount = amtMatch != null ? double.parse(amtMatch.group(1)!.replaceAll(',', '')) : 0.0;
            final refMatch = refReg.firstMatch(body);
            final bool isDebit = body.toLowerCase().contains("debited") || body.toLowerCase().contains("paid");

            parsed = TransactionModel(
              referenceNumber: refMatch != null ? refMatch.group(1)! : "DSH-${message.date!.millisecondsSinceEpoch}",
              amount: isDebit ? -amount : amount,
              resultingBalance: balance,
              rawSender: "Dashen",
              accountLabel: "Dashen Acc",
              typeLabel: isDebit ? "DEBITED" : "RECEIVED",
              transactionDate: message.date!,
              depositorName: "Dashen Channel",
            );
          }
        }
      } catch (_) {}

      if (parsed != null) {
        syncBuffer.add(parsed);
      }
    }

    syncBuffer.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    _transactions = syncBuffer;
    
    notifyListeners(); 
  }

  // --- Supplementary App Configuration Handlers ---
  void completeOnboarding() {
    _isFirstTimeUser = false;
    notifyListeners();
  }

  void updateApiKey(String key, String provider) {
    _apiKey = key;
    notifyListeners();
  }

  void toggleTheme(bool dark) {
    _isDarkMode = dark;
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