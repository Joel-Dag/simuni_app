// lib/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'secure_storage_service.dart';
import 'analytics_engine.dart';
import 'database_helper.dart';
import 'transaction_model.dart';
import 'sms_history_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storage = SecureStorageService();
  final _analytics = AnalyticsEngine();
  final _dbHelper = DatabaseHelper();
  final _smsSync = SmsHistoryService();

  String _accountMask = "Loading...";
  String _accountNickname = "Account";
  double _realBalance = 0.0;
  double _monthlyVelocity = 0.0;
  double _safeToSpend = 0.0;
  List<TransactionModel> _historyList = [];
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceStateData();
  }

  Future<void> _loadDeviceStateData() async {
    final mask = await _storage.getAccountMask() ?? "1000*****0000";
    final nickname = await _storage.getAccountNickname() ?? "Primary Ledger";
    final metrics = await _analytics.calculateLiveMetrics();
    final txHistory = await _dbHelper.fetchTransactions();

    setState(() {
      _accountMask = mask;
      _accountNickname = nickname;
      _realBalance = metrics['realBalance'] ?? 0.0;
      _monthlyVelocity = metrics['monthlyVelocity'] ?? 0.0;
      _safeToSpend = metrics['safeToSpendDaily'] ?? 0.0;
      _historyList = txHistory;
    });
  }

  Future<void> _triggerManualDeltaSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    await _smsSync.syncSmsInbox();
    await _loadDeviceStateData();

    setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F12),
        elevation: 0,
        title: Text(
          "ስሙኒ // $_accountNickname",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _triggerManualDeltaSync,
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blueAccent,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDeviceStateData,
        color: Colors.blueAccent,
        backgroundColor: const Color(0xFF16161F),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF16161F), Color(0xFF111116)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF262636)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _accountMask,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Icon(
                          Icons.sensors,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "ACTIVE AGGREGATED LEDGER BALANCE",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${_realBalance.toStringAsFixed(2)} ETB",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryNode(
                      "SAFE-TO-SPEND / DAY",
                      "${_safeToSpend.toStringAsFixed(2)} ETB",
                      Icons.shield_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTelemetryNode(
                      "60D VELOCITY",
                      "${_monthlyVelocity.toStringAsFixed(2)} ETB",
                      Icons.bolt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                "PARSED LEDGER TIMELINE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              if (_historyList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      "No incoming account records tracked yet.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _historyList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final tx = _historyList[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E1E2A)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.depositorName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tx.referenceNumber,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "+${tx.amount.toStringAsFixed(2)} ETB",
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${tx.transactionDate.day}/${tx.transactionDate.month}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryNode(String title, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262636)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 18),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
