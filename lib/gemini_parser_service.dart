// lib/gemini_parser_service.dart
import 'transaction_model.dart';

class GeminiParserService {
  Future<TransactionModel?> parseSmsBody(String body, DateTime smsDate) async {
    try {
      final lowerBody = body.toLowerCase();

      // 1. Strict Filter: Only process messages belonging to CBE account identifiers matching your criteria
      if (!lowerBody.contains("account 1") && !lowerBody.contains("acc 1")) return null;
      
      // Look for explicit transaction keywords
      bool isDeposit = lowerBody.contains("credited") || lowerBody.contains("received") || lowerBody.contains("deposited");
      bool isExpense = lowerBody.contains("debited") || lowerBody.contains("sent");
      
      if (!isDeposit && !isExpense) return null;

      // 2. High-Fidelity Extraction Patterns
      // Captures amount variations like: "ETB 2200", "ETB 4,000.00", "Amt: 150.00 ETB"
      final amtRegex = RegExp(r'(?:etb|amt:)\s*([0-9,]+\.[0-9]{2}|[0-9,]+)');
      // Extracts unique transaction IDs or reference keys (e.g., FT251047GBTF, TT16006HSWR4)
      final refRegex = RegExp(r'(?:ref:|id:|invoice no)\s*([a-z0-9]{10,})', caseSensitive: false);
      // Grabs full 13-digit accounts starting with 1000 or the masked variation (e.g. 1********3866)
      final accRegex = RegExp(r'(?:account|acc)\s+([0-9\*]{10,15})', caseSensitive: false);

      final amtMatch = amtRegex.firstMatch(lowerBody);
      final refMatch = refRegex.firstMatch(lowerBody);
      final accMatch = accRegex.firstMatch(lowerBody);

      if (amtMatch == null) return null;

      // Clean string separators to compute mathematical operations securely
      double parsedAmount = double.parse(amtMatch.group(1)!.replaceAll(',', ''));
      
      // If the message signifies money spent/sent/debited, tag it as a negative transaction value
      if (isExpense) {
        parsedAmount = -parsedAmount;
      }

      // Generate localized data points if details aren't explicitly structured inside standard payloads
      String referenceKey = refMatch != null 
          ? refMatch.group(1)!.toUpperCase() 
          : "CBE-${smsDate.millisecondsSinceEpoch.toString().substring(6)}";

      String extractedAccount = accMatch != null 
          ? accMatch.group(1)!.toUpperCase() 
          : "1000XXXXXXXXX";

      // Label description context for clear mapping on your parsed dashboard timeline
      String activityLabel = isDeposit 
          ? "Incoming Transfer ($extractedAccount)" 
          : "Outgoing Payment ($extractedAccount)";

      return TransactionModel(
        referenceNumber: referenceKey,
        amount: parsedAmount,
        depositorName: activityLabel,
        transactionDate: smsDate,
      );
    } catch (_) {
      // Gracefully bypass structural anomalies without breaking background streams
      return null;
    }
  }
}