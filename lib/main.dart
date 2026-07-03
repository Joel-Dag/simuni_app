// lib/main.dart

import 'package:flutter/material.dart';
import 'secure_storage_service.dart';
import 'api_key_screen.dart';
import 'dashboard_screen.dart';

void main() async {
  // 1. Guard native platform channels to prevent storage calls before engine attachment
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Query secure device keys to determine state direction
  final storageService = SecureStorageService();
  final String? savedKey = await storageService.getApiKey();

  // 3. Launch application
  runApp(SimuniApp(hasApiKey: savedKey != null));
}

class SimuniApp extends StatefulWidget {
  final bool hasApiKey;

  const SimuniApp({super.key, required this.hasApiKey});

  @override
  State<SimuniApp> createState() => _SimuniAppState();
}

class _SimuniAppState extends State<SimuniApp> {
  late bool _setupComplete;

  @override
  void initState() {
    super.initState();
    _setupComplete = widget.hasApiKey;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ስሙኒ',
      debugShowCheckedModeBanner: false,
      
      // ─── UNIFIED HIGH-FIDELITY OBSIDIAN PALETTE ───
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F12),
        primaryColor: Colors.blueAccent,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.blueAccent,
          selectionColor: Color(0xFF262636),
          selectionHandleColor: Colors.blueAccent,
        ),
      ),
      
      // Dynamic routing switch handles app onboarding gracefully
      home: _setupComplete
          ? const DashboardScreen()
          : ApiKeyScreen(
              onSetupComplete: () {
                setState(() {
                  _setupComplete = true;
                });
              },
            ),
    );
  }
}