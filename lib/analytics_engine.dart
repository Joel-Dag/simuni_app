// lib/analytics_engine.dart
import 'database_helper.dart';

class AnalyticsEngine {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<Map<String, double>> calculateLiveMetrics() async {
    final transactions = await _dbHelper.fetchTransactions();
    
    double totalDeposited = 0.0;
    double currentMonthVolume = 0.0;
    final now = DateTime.now();

    for (var tx in transactions) {
      totalDeposited += tx.amount;
      if (tx.transactionDate.month == now.month && tx.transactionDate.year == now.year) {
        currentMonthVolume += tx.amount;
      }
    }

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day + 1;
    double safeToSpendDaily = totalDeposited > 0 ? (totalDeposited / (daysLeft > 0 ? daysLeft : 1)) : 0.0;

    return {
      'realBalance': totalDeposited,
      'monthlyVelocity': currentMonthVolume,
      'safeToSpendDaily': safeToSpendDaily,
    };
  }
}