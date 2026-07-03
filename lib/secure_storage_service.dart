// lib/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  
  static const _keyName = 'simuni_gemini_api_key';
  static const _accountNumberKey = 'simuni_target_account';
  static const _accountMaskKey = 'simuni_account_mask';
  static const _accountNicknameKey = 'simuni_account_nickname';

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _keyName, value: apiKey.trim());
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: _keyName);
  }

  /// Securely saves configurations for the targeted transaction account.
  /// Automatically generates the 13-digit masked variant (e.g., 1000*****4911).
  Future<void> saveAccountProfile({required String fullAccount, required String nickname}) async {
    final cleaned = fullAccount.replaceAll(RegExp(r'\s+'), '').trim();
    await _storage.write(key: _accountNumberKey, value: cleaned);
    await _storage.write(key: _accountNicknameKey, value: nickname.trim());
    
    if (cleaned.length >= 13) {
      final start = cleaned.substring(0, 4);
      final end = cleaned.substring(cleaned.length - 4);
      final mask = "$start*****$end";
      await _storage.write(key: _accountMaskKey, value: mask);
    } else {
      await _storage.write(key: _accountMaskKey, value: cleaned);
    }
  }

  Future<String?> getAccountMask() async => await _storage.read(key: _accountMaskKey);
  Future<String?> getAccountNickname() async => await _storage.read(key: _accountNicknameKey);

  Future<void> deleteApiKey() async {
    await _storage.deleteAll();
  }
}