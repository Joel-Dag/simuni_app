// lib/sms_history_service.dart
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'transaction_model.dart';
import 'sms_parser.dart';

class SmsHistoryService {
  final _smsQuery = SmsQuery();

  Future<List<TransactionModel>> syncSmsInbox({DateTime? since}) async {
    final ninetyDaysAgo = since ?? DateTime.now().subtract(const Duration(days: 90));
    
    try {
      final messages = await _smsQuery.querySms(
        kinds: [SmsQueryKind.inbox],
      );

      final transactions = <TransactionModel>[];
      for (var msg in messages) {
        if (msg.date == null || msg.date!.isBefore(ninetyDaysAgo)) continue;
        
        final parsed = SmsParser.parse(
          body: msg.body ?? '',
          sender: msg.sender ?? '',
          timestamp: msg.date!,
        );
        
        if (parsed != null) {
          transactions.add(parsed);
        }
      }

      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      return transactions;
    } catch (e) {
      // SMS sync failed - silently return empty list
      return [];
    }
  }
}