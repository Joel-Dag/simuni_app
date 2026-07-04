// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'app_state.dart';
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'ai_advisor_screen.dart';
import 'settings_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const SimuniApp(),
    ),
  );
}

class SimuniApp extends StatelessWidget {
  const SimuniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simuni Ledger',
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        fontFamily: appState.currentFont,
        brightness: Brightness.light,
        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: appState.fontSize)),
      ),
      darkTheme: ThemeData(
        fontFamily: appState.currentFont,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: appState.fontSize, color: Colors.white)),
      ),
      home: appState.isFirstTimeUser ? const OnboardingWizard() : const MainNavigationShell(),
    );
  }
}

// ─── ONBOARDING WIZARD SCREEN ───────────────────────────────────────────────
class OnboardingWizard extends StatefulWidget {
  const OnboardingWizard({super.key});

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  final TextEditingController _apiController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSmsPermissionAndSync(AppState state) async {
    setState(() => _isLoading = true);
    final status = await Permission.sms.request();
    
    if (status.isGranted) {
      final SmsQuery query = SmsQuery();
      await query.querySms(kinds: [SmsQueryKind.inbox]);
      // Filter & process matching shortcodes (CBE, Telebirr) inside background stream here
      // state.loadParsedHistory(processedItems);
    }
    
    // Save profile metadata and advance application state cleanly
    state.createNewProfile(_nameController.text.trim().isEmpty ? "Default Profile" : _nameController.text.trim());
    if (_apiController.text.isNotEmpty) {
      state.updateApiKey(_apiController.text.trim(), "Gemini");
    }
    state.completeOnboarding();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Simuni // Ledger Setup", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text("Sync hardware transaction ledgers with local machine intelligence.", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Profile Owner Name", labelStyle: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apiController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Gemini API Key (Optional - Free tier supported)", 
                  labelStyle: TextStyle(color: Colors.grey),
                  helperText: "Can be added manually later inside settings terminal configurations.",
                  helperStyle: TextStyle(color: Color(0xFF4DA3FF))
                ),
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2EE59D))))
              else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2EE59D), minimumSize: const Size.fromHeight(50)),
                  onPressed: () => _handleSmsPermissionAndSync(appState),
                  child: const Text("Grant SMS Access & Sync Ledger", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    appState.createNewProfile("Guest Space");
                    appState.completeOnboarding();
                  },
                  child: const Center(child: Text("Skip Setup Configuration", style: TextStyle(color: Colors.grey))),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// ─── PRINCIPAL NAVIGATION SHELL INTERFACE ────────────────────────────────────
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    final List<Widget> screens = [
      HomeScreen(appState: appState),
      const TransactionsScreen(),
      const AnalyticsScreen(),
      const BudgetScreen(),
      const AiAdvisorScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: screens),
          Positioned(left: 14, right: 14, bottom: 20, child: _buildPremiumGlassNavBar()),
        ],
      ),
    );
  }

  Widget _buildPremiumGlassNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF182233).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF222F47), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.wallet_rounded, "Home"),
          _navItem(1, Icons.receipt_long_rounded, "Streams"),
          _navItem(2, Icons.analytics_rounded, "Velocity"),
          _navItem(3, Icons.shield_rounded, "Safety"),
          _navItem(4, Icons.auto_awesome_rounded, "Advisor"),
          _navItem(5, Icons.tune_rounded, "Config"),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    Color activeColor = index == 4 ? const Color(0xFFF7C948) : const Color(0xFF4DA3FF);
    if (index == 5) activeColor = Colors.white.withValues(alpha: 0.75);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? activeColor : Colors.grey[500], size: isSelected ? 22 : 20),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : (Colors.grey[600] ?? Colors.grey).withValues(alpha: 0.75), fontSize: 9)),
        ],
      ),
    );
  }
}