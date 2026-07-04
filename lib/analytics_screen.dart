// lib/analytics_screen.dart
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _timeFrame = "This Month";

  // Data mapping the structural spending velocity
  final List<Map<String, dynamic>> _categories = [
    {"name": "Food & Delivery", "amount": "-8,400 ETB", "percentage": 0.42, "count": "18 transactions", "color": const Color(0xFFFF5A6A)},
    {"name": "Transport & Ride", "amount": "-4,800 ETB", "percentage": 0.24, "count": "24 transactions", "color": const Color(0xFFF7C948)},
    {"name": "Rent & Utilities", "amount": "-4,000 ETB", "percentage": 0.20, "count": "2 transactions", "color": const Color(0xFF4DA3FF)},
    {"name": "Tech & Subscriptions", "amount": "-2,800 ETB", "percentage": 0.14, "count": "5 transactions", "color": Colors.purpleAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14), // Deep Black Base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Financial Velocity",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          _buildTimeframeDropdown(),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildOutflowHeroCard(),
            const SizedBox(height: 28),
            Text(
              "SPENDING CHANNELS",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _buildCategoryFlowList(),
            ),
          ],
        ),
      ),
    );
  }

  // Apple UI Style clean toggle menu
  Widget _buildTimeframeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF182233),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222F47)),
      ),
      child: DropdownButton<String>(
        value: _timeFrame,
        dropdownColor: const Color(0xFF121824),
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        onChanged: (String? newValue) {
          if (newValue != null) setState(() => _timeFrame = newValue);
        },
        items: <String>['This Week', 'This Month', 'Quarterly']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  // Hero Card isolating the core question: Why did it happen?
  Widget _buildOutflowHeroCard() {
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
          Text(
            "TOTAL OUTFLOW MATRIX",
            style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          const Text(
            "20,000.00 ETB",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFF1A2336), thickness: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFFF7C948), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Food & Transport velocity account for 66% of all debited volumes.",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.4),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Proportional Visual spending distribution flows
  Widget _buildCategoryFlowList() {
    return ListView.separated(
      itemCount: _categories.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final double pct = cat["percentage"];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat["name"],
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat["count"],
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      cat["amount"],
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 14, 
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(pct * 100).toStringAsFixed(0)}%",
                      style: TextStyle(color: cat["color"], fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // High fidelity comparative background track bar
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF182233),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: cat["color"],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}