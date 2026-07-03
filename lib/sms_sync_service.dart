// lib/sms_sync_service.dart
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'transaction_model.dart';
import 'gemini_parser_service.dart';

class SmsSyncService {
  final SmsQuery _query = SmsQuery();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GeminiParserService _parser = GeminiParserService();

  Future<void> syncSmsInbox({DateTime? since, Function(double)? onProgress}) async {
    var permission = await Permission.sms.status;
    if (!permission.isGranted) {
      permission = await Permission.sms.request();
      if (!permission.isGranted) return;
    }

    final DateTime thresholdDate = since ?? DateTime.now().subtract(const Duration(days: 3));
    
    List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      address: '8011',
    );

    List<SmsMessage> filteredMessages = messages.where((msg) {
      if (msg.date == null) return false;
      return msg.date!.isAfter(thresholdDate);
    }).toList();

    if (filteredMessages.isEmpty) {
      if (onProgress != null) onProgress(1.0);
      return;
    }

    for (int i = 0; i < filteredMessages.length; i++) {
      final msg = filteredMessages[i];
      if (msg.body != null) {
        TransactionModel? parsedTx = await _parser.parseSmsBody(msg.body!, msg.date ?? DateTime.now());
        if (parsedTx != null) {
          await _dbHelper.insertTransaction(parsedTx);
        }
      }
      if (onProgress != null) {
        onProgress((i + 1) / filteredMessages.length);
      }
    }
  }
}