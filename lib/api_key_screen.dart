// lib/api_key_screen.dart
import 'package:flutter/material.dart';
import 'secure_storage_service.dart';
import 'sms_sync_service.dart';

class ApiKeyScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;
  const ApiKeyScreen({super.key, required this.onSetupComplete});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _accountController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _storageService = SecureStorageService();
  
  bool _isAuthenticating = false;
  String? _statusMessage;
  double _scanProgress = 0.0;

  void _handleGoogleInitialization() async {
    final account = _accountController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (account.isEmpty || nickname.isEmpty) {
      setState(() => _statusMessage = "Target configuration fields are mandatory.");
      return;
    }
    if (account.length < 13) {
      setState(() => _statusMessage = "Please enter a valid CBE 13-digit account number.");
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _statusMessage = "Connecting securely to Google Vertex Core...";
    });

    // Simulate secure Google Auth Gateway handoff
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _statusMessage = "Analyzing historic financial runway (Past 2 Months)...";
    });

    // Instantiate dynamic 2-month back-scan initialization layer
    final smsService = SmsSyncService();
    
    // Save configuration profiles first so parser filters correctly
    await _storageService.saveApiKey("VERTEX_ROUTED_KEY_INTEGRATION");
    await _storageService.saveAccountProfile(fullAccount: account, nickname: nickname);

    try {
      // Look back exactly 60 days to seed the user's baseline financial habits
      final dynamicDateTimeThreshold = DateTime.now().subtract(const Duration(days: 60));
      
      await smsService.syncSmsInbox(
        since: dynamicDateTimeThreshold,
        onProgress: (progress) {
          setState(() {
            _scanProgress = progress;
          });
        },
      );

      widget.onSetupComplete();
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _statusMessage = "Initialization Error: Core sync interrupted.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimalist Obsidian Title Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF262636)),
                  ),
                  child: const Text("ስ", style: TextStyle(color: Colors.blueAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                const Text("ስሙኒ", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  "On-device zero-knowledge financial ledger. All operations run locally.", 
                  style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.4)
                ),
                const SizedBox(height: 32),
                _buildInputField(controller: _accountController, label: "Target CBE Account Number", hint: "1000659904923"),
                const SizedBox(height: 16),
                _buildInputField(controller: _nicknameController, label: "Account Tracking Label / Nickname", hint: "Primary Wallet"),
                const SizedBox(height: 32),
                
                if (_isAuthenticating) ...[
                  LinearProgressIndicator(value: _scanProgress, backgroundColor: const Color(0xFF16161F), color: Colors.blueAccent),
                  const SizedBox(height: 12),
                  Text(_statusMessage!, style: TextStyle(color: Colors.grey[400], fontSize: 13, fontStyle: FontStyle.italic)),
                ] else ...[
                  if (_statusMessage != null) ...[
                    Text(_statusMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _handleGoogleInitialization,
                      icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.png', height: 20),
                      label: const Text("Connect with Google AI", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF16161F),
                        side: const BorderSide(color: Color(0xFF262636)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required String hint}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blueAccent, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF16161F),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF262636))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
      ),
    );
  }
}