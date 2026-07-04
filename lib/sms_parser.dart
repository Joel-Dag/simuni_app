import 'transaction_model.dart'; // Changed from '../models/transaction_model.dart'

class SmsParser {
  static TransactionModel? parse({
    required String body,
    required String sender,
    required DateTime timestamp,
  }) {
    final cleanSender = sender.toUpperCase();
    
    if (cleanSender.contains("CBE") || body.contains("Commercial Bank")) {
      return _parseCbe(body, timestamp);
    } else if (cleanSender.contains("TELEBIRR") || cleanSender.contains("127")) {
      return _parseTelebirr(body, timestamp);
    }
    return null;
  }

  static TransactionModel? _parseCbe(String body, DateTime date) {
    try {
      final amtReg = RegExp(r'(?:ETB|debited|credited|received)\s*([\d,]+\.\d{2})');
      final balReg = RegExp(r'(?:balance is|bal:?)\s*(?:ETB)?\s*([\d,]+\.\d{2})', caseSensitive: false);
      final refReg = RegExp(r'(?:Ref|Txn|ID):\s*([A-Z0-9]+)', caseSensitive: false);
      final accReg = RegExp(r'(?:account|acc\.)\s*([0-9\*]+)');

      final amtMatch = amtReg.firstMatch(body);
      final balMatch = balReg.firstMatch(body);
      final refMatch = refReg.firstMatch(body);
      final accMatch = accReg.firstMatch(body);

      if (balMatch == null) return null; 

      final double balance = double.parse(balMatch.group(1)!.replaceAll(',', ''));
      final double amount = amtMatch != null ? double.parse(amtMatch.group(1)!.replaceAll(',', '')) : 0.0;
      final String ref = refMatch != null ? refMatch.group(1)! : "REF-${date.millisecondsSinceEpoch}";
      final String acc = accMatch != null ? accMatch.group(1)! : "CBE-Acc";
      
      final bool isDebit = body.toLowerCase().contains("debited") || body.toLowerCase().contains("paid");

      return TransactionModel(
  referenceNumber: ref,
  amount: isDebit ? -amount : amount,
  resultingBalance: balance,
  rawSender: "CBE",
  accountLabel: acc,
  typeLabel: isDebit ? "DEBITED" : "RECEIVED",
  transactionDate: date,
  depositorName: acc, // Pass account identifier as default name map
);
    } catch (_) {
      return null;
    }
  }

  static TransactionModel? _parseTelebirr(String body, DateTime date) {
    try {
      final amtReg = RegExp(r'(?:received|transferred|paid)\s*ETB\s*([\d,]+\.\d{2})', caseSensitive: false);
      final balReg = RegExp(r'(?:balance is|bal:?)\s*ETB\s*([\d,]+\.\d{2})', caseSensitive: false);
      final refReg = RegExp(r'(?:ID|Txn):\s*([0-9A-Za-z]+)', caseSensitive: false);

      final amtMatch = amtReg.firstMatch(body);
      final balMatch = balReg.firstMatch(body);
      final refMatch = refReg.firstMatch(body);

      if (balMatch == null) return null;

      final double balance = double.parse(balMatch.group(1)!.replaceAll(',', ''));
      final double amount = amtMatch != null ? double.parse(amtMatch.group(1)!.replaceAll(',', '')) : 0.0;
      final String ref = refMatch != null ? refMatch.group(1)! : "TLB-${date.millisecondsSinceEpoch}";
      
      final bool isDebit = body.toLowerCase().contains("paid") || body.toLowerCase().contains("transferred to");

      return TransactionModel(
  referenceNumber: ref,
  amount: isDebit ? -amount : amount,
  resultingBalance: balance,
  rawSender: "Telebirr",
  accountLabel: "Mobile Wallet",
  typeLabel: isDebit ? "DEBITED" : "RECEIVED",
  transactionDate: date,
  depositorName: "Telebirr User", 
);
    } catch (_) {
      return null;
    }
  }
}