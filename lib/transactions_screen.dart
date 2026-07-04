// lib/transactions_screen.dart
import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Income", "Expenses", "CBE", "Telebirr"];

  // Pre-compiled transaction stream records matching your exact tracking criteria
  final List<Map<String, dynamic>> _mockTransactions = [
    {
      "title": "CBE Transfer Received",
      "subtitle": "Ref: FT26185GHYT2 • Acc: 1000****3866",
      "amount": "+4,500.00 ETB",
      "date": "Today, 2:14 PM",
      "isIncome": true,
      "tag": "Income",
      "bank": "CBE"
    },
    {
      "title": "Telebirr Merchant Payment",
      "subtitle": "Ref: TXN983210492 • Acc: 0944****21",
      "amount": "-1,250.50 ETB",
      "date": "Yesterday, 6:45 PM",
      "isIncome": false,
      "tag": "Expenses",
      "bank": "Telebirr"
    },
    {
      "title": "ATM Cash Withdrawal",
      "subtitle": "Ref: WT16006HSWR4 • Acc: 1000****3866",
      "amount": "-2,000.00 ETB",
      "date": "29 Jun, 10:15 AM",
      "isIncome": false,
      "tag": "Expenses",
      "bank": "CBE"
    },
    {
      "title": "Salary Deposited",
      "subtitle": "Ref: FT26177MQLK1 • Acc: 1000****9912",
      "amount": "+32,400.00 ETB",
      "date": "25 Jun, 8:00 AM",
      "isIncome": true,
      "tag": "Income",
      "bank": "CBE"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic handling interactive state selections smoothly
    final filteredTx = _mockTransactions.where((tx) {
      if (_selectedFilter == "All") return true;
      if (_selectedFilter == "Income") return tx["isIncome"] == true;
      if (_selectedFilter == "Expenses") return tx["isIncome"] == false;
      return tx["bank"] == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14), // Deep Black Base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Ledger Stream",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF4DA3FF)), // System Blue Filter Icon
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
            _buildSearchDisplayBar(),
            const SizedBox(height: 20),
            _buildFilterChips(),
            const SizedBox(height: 28),
            Text(
              "TRANSACTION HISTORY (${filteredTx.length})",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _buildHistoryStream(filteredTx),
            ),
          ],
        ),
      ),
    );
  }

  // Apple UI Style Translucent Search Indicator Area
  Widget _buildSearchDisplayBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121824), // Surface Base
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A2336)),
      ),
      child: Row(
        children: [
          Icon(Icons.manage_search_rounded, color: Colors.grey[500], size: 20),
          const SizedBox(width: 12),
          Text(
            "Filter by reference key, account, or status...",
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Interactive Filter Segment Line
  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF182233) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF4DA3FF) : const Color(0xFF1A2336),
                  width: 1.2,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[500],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // The Primary Structural Stream Timeline
  Widget _buildHistoryStream(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          "No matched transactions in this target matrix.",
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      itemCount: transactions.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx["isIncome"] as bool;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF121824), // Surface layer container mapping
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1A2336)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Dynamic status directional color circle badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isIncome
                            ? const Color(0xFF2EE59D).withOpacity(0.06)
                            : const Color(0xFFFF5A6A).withOpacity(0.06),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isIncome
                              ? const Color(0xFF2EE59D).withOpacity(0.15)
                              : const Color(0xFFFF5A6A).withOpacity(0.15),
                        ),
                      ),
                      child: Icon(
                        isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                        color: isIncome ? const Color(0xFF2EE59D) : const Color(0xFFFF5A6A),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx["title"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tx["subtitle"],
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tx["amount"],
                    style: TextStyle(
                      color: isIncome ? const Color(0xFF2EE59D) : const Color(0xFFFF5A6A),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace', // Keep strict financial geometry alignment
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tx["date"],
                    style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}