// lib/gemini_parser_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'secure_storage_service.dart';
import 'transaction_model.dart';

class GeminiParserService {
  final _storageService = SecureStorageService();

  Future<TransactionModel?> parseTransactionSms(String rawSmsText, DateTime smsTime) async {
    final apiKey = await _storageService.getApiKey();
    final targetMask = await _storageService.getAccountMask();
    
    if (apiKey == null || targetMask == null) {
      debugPrint("ስሙኒ Error: Missing api validation parameters.");
      return null;
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'amount': Schema.number(description: 'The exact currency value transacted.'),
            'depositor_name': Schema.string(description: 'The sender name in ALL CAPS. Use UNKNOWN if unidentifiable.'),
            'reference_number': Schema.string(description: 'The alphanumeric transaction reference identifier code.'),
            'is_incoming_deposit': Schema.boolean(description: 'True if credit entry, false if debit/withdrawal.'),
            'matches_target_account': Schema.boolean(description: 'True ONLY if the message specifies it belongs to the dynamic account target mask specified in instructions.'),
          },
        ),
      ),
    );

    final prompt = [
      Content.text(
        "You are the structural isolated financial engine core for ስሙኒ (Simuni).\n"
        "Your absolute filter objective is to isolate messages belonging to this exact bank account identifier mask: \"$targetMask\".\n"
        "CBE typically logs this format inside notification texts as \"account 1000*****4923\" or similar variants.\n"
        "If the text does not match this specific layout identifier, set 'matches_target_account' to false.\n\n"
        "Target message payload raw content:\n\"$rawSmsText\""
      )
    ];

    try {
      final response = await model.generateContent(prompt);
      final jsonText = response.text;
      if (jsonText == null) return null;

      final Map<String, dynamic> parsedJson = jsonDecode(jsonText);

      // Strict enforcement drop layer filters out foreign accounts and outbound cash flow
      if (parsedJson['matches_target_account'] != true || parsedJson['is_incoming_deposit'] == false) {
        return null; 
      }

      return TransactionModel(
        referenceNumber: parsedJson['reference_number']?.toString().toUpperCase().trim() ?? '',
        depositorName: parsedJson['depositor_name']?.toString().toUpperCase().trim() ?? 'UNKNOWN',
        amount: (parsedJson['amount'] as num).toDouble(),
        transactionDate: smsTime,
        rawSmsBody: rawSmsText,
      );
    } catch (e) {
      debugPrint("ስሙኒ Filtering System Exception: $e");
      return null;
    }
  }
}