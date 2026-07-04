// lib/main.dart
import 'package:flutter/material.dart';
import 'app_state.dart';
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'ai_advisor_screen.dart';

void main() {
  runApp(const SimuniApp());
}

class SimuniApp extends StatelessWidget {
  const SimuniApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simuni Ledger',
      theme: ThemeData(
        fontFamily: 'Inter',
        brightness: Brightness.dark,
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  // Ordered layout array map adhering strictly to your structural philosophy
  late final List<Widget> _screens = [
    HomeScreen(appState: _appState),         // 1. Home -> "How much money do I have?"
    const TransactionsScreen(), // 2. Transactions -> "What happened?"
    const AnalyticsScreen(),    // 3. Analytics -> "Why did it happen?"
    const BudgetScreen(),       // 4. Budget -> "Am I safe?"
    const AiAdvisorScreen(),    // 5. AI -> "What should I do?"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14), // Core Deep Black
      body: Stack(
        children: [
          // Render selected matrix screen indexed cleanly
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // Floating Glass Navigation Hub anchored over the workspace
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildPremiumGlassNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumGlassNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF182233).withOpacity(0.94), // Blended Translucent Surface
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF222F47), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.wallet_rounded, "Home"),
          _navItem(1, Icons.receipt_long_rounded, "Streams"),
          _navItem(2, Icons.analytics_rounded, "Velocity"),
          _navItem(3, Icons.shield_rounded, "Safety"),
          _navItem(4, Icons.auto_awesome_rounded, "Advisor"),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    // Map individual visual identities across contextual states smoothly
    final Color activeColor = index == 4 
        ? const Color(0xFFF7C948) // Gold highlight for AI Advisor
        : const Color(0xFF4DA3FF); // System Blue for core tracks

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        width: 55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
              transform: isSelected ? Matrix4.translationValues(0, -2, 0) : Matrix4.identity(),
              child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey[500],
                size: isSelected ? 24 : 21,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}