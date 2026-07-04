// lib/budget_screen.dart
import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // Budget boundary records mapping current allocations against real-time consumption
  final List<Map<String, dynamic>> _budgets = [
    {
      "title": "Monthly Essentials",
      "spent": "14,500 ETB",
      "limit": "20,000 ETB",
      "ratio": 0.725,
      "color": const Color(0xFF2EE59D), // Emerald Green (Safe margin)
      "status": "7,500 ETB remaining"
    },
    {
      "title": "Dining & Entertainment",
      "spent": "8,400 ETB",
      "limit": "9,000 ETB",
      "ratio": 0.933,
      "color": const Color(0xFFFF5A6A), // Soft Red (Burn warning)
      "status": "600 ETB remaining • Over velocity"
    },
    {
      "title": "Transport & Tech Setup",
      "spent": "4,800 ETB",
      "limit": "10,000 ETB",
      "ratio": 0.48,
      "color": const Color(0xFF4DA3FF), // System Blue (Stable status)
      "status": "5,200 ETB remaining"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14), // Deep Black Base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Safety Matrix",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_moderator_rounded, color: Color(0xFF2EE59D)),
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
            _buildSafetyStatusHero(),
            const SizedBox(height: 32),
            Text(
              "ACTIVE SPENDING LIMITS",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _buildBudgetMatrixList(),
            ),
          ],
        ),
      ),
    );
  }

  // Hero Shield Container directly isolating the screen's core question: Am I Safe?
  Widget _buildSafetyStatusHero() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SAFE-TO-SPEND STATUS",
                style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2EE59D).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2EE59D).withValues(alpha: 0.2)),
                ),
                child: const Text(
                  "SECURE",
                  style: TextStyle(color: Color(0xFF2EE59D), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "1,200 ETB / Day",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Recommended baseline pace to match your saving goal targets.",
            style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Visual Boundary Monitoring Matrix Cards
  Widget _buildBudgetMatrixList() {
    return ListView.separated(
      itemCount: _budgets.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final allocation = _budgets[index];
        final double ratio = allocation["ratio"];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF121824), // Surface Base
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1A2336)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    allocation["title"],
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      Text(
                        allocation["spent"],
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                      Text(
                        " / ${allocation["limit"]}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // High-contrast translucent indicator track
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF182233),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: allocation["color"],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                allocation["status"],
                style: TextStyle(
                  color: ratio > 0.9 ? const Color(0xFFFF5A6A) : Colors.grey[500],
                  fontSize: 11,
                  fontWeight: ratio > 0.9 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}