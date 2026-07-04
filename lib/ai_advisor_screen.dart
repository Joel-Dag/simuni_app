// lib/ai_advisor_screen.dart
import 'package:flutter/material.dart';

class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({Key? key}) : super(key: key);

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  // Mocking deep engine insights mapped straight from bank transaction telemetry
  final List<Map<String, dynamic>> _strategicActions = [
    {
      "type": "OPTIMIZE",
      "icon": Icons.auto_awesome_rounded,
      "color": const Color(0xFFF7C948), // Gold Accent
      "title": "Mitigate Subscription Leaks",
      "description": "You have 3 parallel digital streaming streams active via CBE ledger logs. Consolidating accounts could yield 450 ETB in immediate monthly relief.",
      "actionLabel": "Review Subscriptions"
    },
    {
      "type": "SURGE ALERT",
      "icon": Icons.trending_up_rounded,
      "color": const Color(0xFFFF5A6A), // Soft Red Accent
      "title": "Transport Velocity Warning",
      "description": "Ride-hailing expenses have surged 31% above your standard baseline over the last 7 days. Limit non-essential travel to remain safe-to-spend.",
      "actionLabel": "Adjust Transport Cap"
    },
    {
      "type": "INVESTMENT ALIGNMENT",
      "icon": Icons.account_balance_wallet_rounded,
      "color": const Color(0xFF4DA3FF), // System Blue Accent
      "title": "Idle Capital Optimization",
      "description": "Your aggregated net standing across Telebirr and CBE accounts has held above safety thresholds for 45 days. Deploy 12,000 ETB into a higher-yield asset.",
      "actionLabel": "Deploy Surplus"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14), // Deep Black Base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Simuni Intelligence",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt_rounded, color: Color(0xFF4DA3FF)),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildAiStatusHero(),
            const SizedBox(height: 32),
            Text(
              "IMMEDIATE STRATEGIC ACTIONS",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _buildInsightActionList(),
            ),
          ],
        ),
      ),
    );
  }

  // Engine Status Hero Card answering: What should I do?
  Widget _buildAiStatusHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF121824), // Surface Base
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1A2336)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Color(0xFF4DA3FF), size: 22),
              const SizedBox(width: 10),
              Text(
                "FORECAST ANALYSIS",
                style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Target Savings: On Track",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Based on your active CBE parser telemetry, maintaining your current daily pace secures your financial health target by month-end.",
            style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Interactive Tactical Execution Cards
  Widget _buildInsightActionList() {
    return ListView.separated(
      itemCount: _strategicActions.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final action = _strategicActions[index];
        final Color accentColor = action["color"];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF121824), // Surface Base
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1A2336)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Category Header
              Row(
                children: [
                  Icon(action["icon"], color: accentColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    action["type"],
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                action["title"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action["description"],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // Glassmorphism Action Execution Trigger
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF182233), // Card Base elevation
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF222F47)),
                  ),
                  child: Center(
                    child: Text(
                      action["actionLabel"],
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}