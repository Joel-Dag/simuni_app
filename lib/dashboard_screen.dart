// lib/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'sms_sync_service.dart';
import 'analytics_engine.dart';
import 'transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SmsSyncService _syncService = SmsSyncService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isSyncing = false;
  final double _bankBalance = 45000.00; // Simulated active account balance baseline
  List<TransactionModel> _transactions = [];
  double _safeToSpend = 0.0;
  int _runwayDays = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final ledger = await _dbHelper.getAllTransactions();
    final pastMonthOutflows = await _dbHelper.getThirtyDayVelocity();

    // Simulated upcoming fixed expense liabilities (e.g., Rent, Wifi)
    List<Map<String, dynamic>> mockExpenses = [
      {'title': 'Rent Due', 'amount': 8500.00},
      {'title': 'Internet Package', 'amount': 1200.00},
    ];

    final computedSafe = AnalyticsEngine.calculateSafeToSpend(
      currentRawBankBalance: _bankBalance,
      upcomingFixedExpenses: mockExpenses,
    );

    final computedRunway = AnalyticsEngine.calculateCashRunwayDays(
      currentLiquidCash: _bankBalance,
      totalOutflowsPastMonth: pastMonthOutflows,
    );

    setState(() {
      _transactions = ledger;
      _safeToSpend = computedSafe;
      _runwayDays = computedRunway;
    });
  }

  Future<void> _triggerSmsSync() async {
    setState(() => _isSyncing = true);
    
    // Fire Stage 4's hardware reader catch-up sync sequence
    await _syncService.syncMissedTransactions();
    await _loadDashboardData();

    if (!mounted) return;
    setState(() => _isSyncing = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ስሙኒ Ledger Sync Complete.'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12), // Premium Obsidian Dark Base
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F12),
        elevation: 0,
        title: const Text(
          "ስሙኒ",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: _isSyncing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent))
              : const Icon(Icons.sync, color: Colors.blueAccent),
            onPressed: _isSyncing ? null : _triggerSmsSync,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: Colors.blueAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── ANALYTICS INFRASTRUCTURE MODULE CARDS ───
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: "Safe-to-Spend",
                      value: "${_safeToSpend.toStringAsFixed(2)} ETB",
                      subtitle: "After fixed obligations",
                      accentColor: const Color(0xFF10B981), // Emerald
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: "Cash Runway",
                      value: _runwayDays == 999 ? "∞" : "$_runwayDays Days",
                      subtitle: "Based on burn velocity",
                      accentColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Automated Income Ledger",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // ─── TRANSACTIONS LOG VIEW ───
              Expanded(
                child: _transactions.isEmpty
                    ? Center(
                        child: Text(
                          "No transactions logged.\nTap sync icon to scan CBE texts.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _transactions.length,
                        separatorBuilder: (context, index) => const Divider(color: Color(0xFF1F1F2E)),
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16161F),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_downward, color: Color(0xFF10B981)),
                            ),
                            title: Text(
                              tx.depositorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            subtitle: Text(
                              tx.referenceNumber,
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "+${tx.amount.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${tx.transactionDate.day}/${tx.transactionDate.month}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF262636)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: accentColor, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        ],
      ),
    );
  }
}