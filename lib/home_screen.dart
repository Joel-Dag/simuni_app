// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'app_state.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState; // Pass state down cleanly from main wrapper matrix

  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Attach listener so UI shifts fluidly when a new bank text enters the device streams
    widget.appState.addListener(_updateUiState);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_updateUiState);
    super.dispose();
  }

  void _updateUiState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    // Dynamic bank records compiled cleanly on every state modification step
    final List<Map<String, dynamic>> dynamicBanks = [
      {"name": "CBE", "balance": state.cbeBalance, "ratio": 0.8, "color": const Color(0xFF2EE59D)},
      {"name": "Telebirr", "balance": state.telebirrBalance, "ratio": 0.6, "color": const Color(0xFF4DA3FF)},
      {"name": "Dashen Bank", "balance": state.dashenBalance, "ratio": 0.4, "color": const Color(0xFFF7C948)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14), // Premium Deep Black Base
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildNetWorthDisplay(state.totalNetWorth),
                const SizedBox(height: 28),
                _buildBankStackSection(dynamicBanks),
                const SizedBox(height: 32),
                _buildTodaySnapshotSection(state.todayIncome, state.todayExpense),
                const SizedBox(height: 28),
                _buildSmartInsightCard(),
                const SizedBox(height: 100), // Action bar buffer space allocation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Simuni",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF182233),
              child: Text("E", style: TextStyle(color: Color(0xFF4DA3FF), fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildNetWorthDisplay(double netWorth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TOTAL NET WORTH",
          style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          "${netWorth.toStringAsFixed(2)} ETB",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: const [
            Icon(Icons.trending_up_rounded, color: Color(0xFF2EE59D), size: 16),
            SizedBox(width: 4),
            Text(
              "+2.4% this month",
              style: TextStyle(color: Color(0xFF2EE59D), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankStackSection(List<Map<String, dynamic>> banks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BANK STACK",
          style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: banks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final bank = banks[index];
              return Container(
                width: 170,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF182233),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF222F47), width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bank["name"],
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${(bank["balance"] as double).toStringAsFixed(0)} ETB",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: bank["ratio"],
                            backgroundColor: const Color(0xFF121824),
                            valueColor: AlwaysStoppedAnimation<Color>(bank["color"]),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySnapshotSection(double income, double expense) {
    double totalNet = income - expense;
    double completionRatio = income == 0 ? 0.0 : (income / (income + expense)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121824),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1A2336), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODAY",
                style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              const SizedBox(height: 16),
              _buildSnapshotMetricRow("+${income.toStringAsFixed(2)} ETB Income", const Color(0xFF2EE59D)),
              const SizedBox(height: 10),
              _buildSnapshotMetricRow("-${expense.toStringAsFixed(2)} ETB Expenses", const Color(0xFFFF5A6A)),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF1A2336), thickness: 1),
              const SizedBox(height: 4),
              _buildSnapshotMetricRow(
                "${totalNet >= 0 ? '=' : '='} ${totalNet >= 0 ? '+' : ''}${totalNet.toStringAsFixed(2)} ETB Net", 
                totalNet >= 0 ? const Color(0xFF2EE59D) : const Color(0xFFFF5A6A), 
                isNet: true
              ),
            ],
          ),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: completionRatio == 0 ? 0.1 : completionRatio,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFF182233),
                  valueColor: AlwaysStoppedAnimation<Color>(totalNet >= 0 ? const Color(0xFF2EE59D) : const Color(0xFFFF5A6A)),
                ),
                Center(
                  child: Text(
                    "${(completionRatio * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      color: totalNet >= 0 ? const Color(0xFF2EE59D) : const Color(0xFFFF5A6A), 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      fontFamily: 'monospace'
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSnapshotMetricRow(String text, Color color, {bool isNet = false}) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: isNet ? 14 : 13, fontWeight: isNet ? FontWeight.bold : FontWeight.w500, fontFamily: 'monospace'),
    );
  }

  Widget _buildSmartInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF7C948).withValues(alpha: 0.07), const Color(0xFF182233)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF7C948).withValues(alpha: 0.25), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFF7C948), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SMART INSIGHT",
                  style: TextStyle(color: Color(0xFFF7C948), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                const SizedBox(height: 6),
                Text(
                  "You could save 4,800 ETB this month if transport spending stabilizes.",
                  style: TextStyle(color: Colors.grey[200], fontSize: 13, height: 1.4, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}