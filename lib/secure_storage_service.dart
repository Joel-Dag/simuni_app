// lib/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveApiKey(String key) async => await _storage.write(key: 'gemini_api_key', value: key);
  Future<String?> getApiKey() async => await _storage.read(key: 'gemini_api_key');

  Future<void> saveAccountProfile({required String fullAccount, required String nickname}) async {
    await _storage.write(key: 'account_nickname', value: nickname);
    String mask = fullAccount.length >= 4 
        ? "${fullAccount.substring(0, 4)}*****${fullAccount.substring(fullAccount.length - 4)}"
        : fullAccount;
    await _storage.write(key: 'account_mask', value: mask);
  }

  Future<String?> getAccountNickname() async => await _storage.read(key: 'account_nickname');
  Future<String?> getAccountMask() async => await _storage.read(key: 'account_mask');
}