// lib/gemini_parser_service.dart
import 'transaction_model.dart';

class GeminiParserService {
  Future<TransactionModel?> parseSmsBody(String body, DateTime smsDate) async {
    try {
      // Direct high-efficiency parser matching Commercial Bank of Ethiopia structures
      if (!body.contains("credited") && !body.contains("received")) return null;

      final amtRegex = RegExp(r'(?:ETB|Amt:)\s*([0-9,]+\.[0-9]{2})');
      final refRegex = RegExp(r'(?:Ref:|ID:)\s*([A-Z0-9]{10,})');
      final nameRegex = RegExp(r'(?:from|by)\s+([A-Za-z\s\.\+]+?)(?=\s+for|\s+at|\s+on|\.$)');

      final amtMatch = amtRegex.firstMatch(body);
      final refMatch = refRegex.firstMatch(body);
      final nameMatch = nameRegex.firstMatch(body);

      if (amtMatch == null || refMatch == null) return null;

      double amount = double.parse(amtMatch.group(1)!.replaceAll(',', ''));
      String ref = refMatch.group(1)!;
      String sender = nameMatch != null ? nameMatch.group(1)!.trim() : "Direct Deposit / Transfer";

      return TransactionModel(
        referenceNumber: ref,
        amount: amount,
        depositorName: sender,
        transactionDate: smsDate,
      );
    } catch (_) {
      return null;
    }
  }
}