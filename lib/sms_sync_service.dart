// lib/sms_sync_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'database_helper.dart';
import 'gemini_parser_service.dart';
import 'transaction_model.dart';

class SmsSyncService {
  final SmsQuery _query = SmsQuery();
  final GeminiParserService _aiParser = GeminiParserService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Scans the physical device inbox, isolates new financial texts since 
  /// the last entry date, and automatically streams them through Gemini.
  Future<void> syncMissedTransactions() async {
    try {
      // 1. Fetch current transaction history to determine our checkpoint time
      final existingTransactions = await _dbHelper.getAllTransactions();
      
      DateTime lastSyncPoint = DateTime.now().subtract(const Duration(days: 30));
      
      if (existingTransactions.isNotEmpty) {
        // Set sync point to the time of our most recent transaction
        lastSyncPoint = existingTransactions.first.transactionDate;
      }

      // 2. Query the device SMS inbox provider
      final List<SmsMessage> rawMessages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
      );

      debugPrint("ስሙኒ Sync: Total texts scanned in inbox: ${rawMessages.length}");

      // 3. Filter down to targeted financial notifications arriving after our last record
      final targetSenders = {'CBE', 'CBEBIRR', '8890', 'E-BIRR'};
      final missedMessages = rawMessages.where((sms) {
        final sender = sms.address?.toUpperCase() ?? '';
        final date = sms.date ?? DateTime.now();
        
        return targetSenders.contains(sender) && date.isAfter(lastSyncPoint);
      }).toList();

      debugPrint("ስሙኒ Sync: Found ${missedMessages.length} un-synced bank texts.");

      // 4. Loop over missed messages and parse sequentially using Gemini
      int successfulParses = 0;
      for (var sms in missedMessages.reversed) {
        if (sms.body == null) continue;

        final TransactionModel? parsedResult = await _aiParser.parseTransactionSms(
          sms.body!,
          sms.date ?? DateTime.now(),
        );

        if (parsedResult != null) {
          await _dbHelper.insertTransaction(parsedResult);
          successfulParses++;
        }
      }

      debugPrint("ስሙኒ Sync Core: Completed. Successfully added $successfulParses new transaction rows.");
    } catch (e) {
      debugPrint("ስሙኒ Sync Core Exception occurred: $e");
    }
  }
}