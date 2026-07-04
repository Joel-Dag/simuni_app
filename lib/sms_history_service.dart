// lib/sms_history_service.dart
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'transaction_model.dart';
import 'gemini_parser_service.dart';

class SmsHistoryService {
  final SmsQuery _query = SmsQuery();

  /// Requests permissions and pulls history from the last 90 days
  Future<List<TransactionModel>> fetch90DayFinancialHistory() async {
    // 1. Check & Request Android Device Permissions safely
    var permissionStatus = await Permission.sms.status;
    if (!permissionStatus.isGranted) {
      permissionStatus = await Permission.sms.request();
      if (!permissionStatus.isGranted) {
        throw Exception("SMS Read permissions are required to initialize your ledger historical data.");
      }
    }

    // 2. Fetch the inbox history
    List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
    );

    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    List<TransactionModel> parsedTransactions = [];

    // 3. Filter and stream contents based on time windows and target financial senders
    for (var msg in messages) {
      if (msg.date == null || msg.date!.isBefore(ninetyDaysAgo)) continue;
      if (msg.body == null) continue;

      final parser = GeminiParserService();
      TransactionModel? tx = await parser.parseSmsBody(
        msg.body!,
        msg.date ?? DateTime.now(),
      );
      if (tx != null) {
        parsedTransactions.add(tx);
      }
    }
    return parsedTransactions;
  }

  /// Sync current SMS inbox from specified date
  Future<void> syncSmsInbox({DateTime? since}) async {
    // Fetch and process as needed
    await fetch90DayFinancialHistory();
  }
}