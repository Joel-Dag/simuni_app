// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// Unified Application Architecture Imports
import 'app_state.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'ai_advisor_screen.dart';
import 'settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const SimUniApp(),
    ),
  );
}

class SimUniApp extends StatelessWidget {
  const SimUniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'SimUni App',
      debugShowCheckedModeBanner: false,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0D1117), // Liquid Neon & Obsidian Design Philosophy
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFCC), 
          secondary: Color(0xFF0066FF),
          surface: Color(0xFF161B22),
        ),
        useMaterial3: true,
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _isSyncing = false;

  // Dynamic getter that dynamically handles explicit state injection without compilation crash rules
  List<Widget> get _screens {
    final appState = Provider.of<AppState>(context, listen: false);
    return [
      HomeScreen(appState: appState), 
      const DashboardScreen(),
      const AnalyticsScreen(),
      const BudgetScreen(),
      const AiAdvisorScreen(),
      const SettingsScreen(),
    ];
  }

  /// High-performance SMS security pipeline. Queries inbox hardware 
  /// data and streams target strings to our functional app_state engine.
  Future<void> _handleSmsSynchronization() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      final permissionStatus = await Permission.sms.request();

      if (permissionStatus.isGranted) {
        final SmsQuery query = SmsQuery();
        final List<SmsMessage> messages = await query.getAllSms;

        if (mounted) {
          Provider.of<AppState>(context, listen: false).syncSmsData(messages);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Financial Sync Completed!'),
              backgroundColor: Color(0xFF00FFCC),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('SMS permission denied. Check device settings.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync error encountered: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves state data maps so tabs don't lose scroll track layout positions
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSyncing ? null : _handleSmsSynchronization,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        child: _isSyncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.sync, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex >= 4 ? 4 : _currentIndex, // Clamps FAB floating indexes
        onDestinationSelected: (int index) {
          // Diverts specific tab clicks into sub-pages seamlessly
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallets',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology_rounded),
            label: 'AI Advisor',
          ),
        ],
      ),
    );
  }
}