// lib/analytics_engine.dart

import 'transaction_model.dart';

class AnalyticsEngine {
  /// Computes the true financial boundary by clearing upcoming liabilities.
  /// Equation: Safe-to-Spend = Current Balance - Upcoming Committed Expenses
  static double calculateSafeToSpend({
    required double currentRawBankBalance,
    required List<Map<String, dynamic>> upcomingFixedExpenses,
  }) {
    double totalCommittedObligations = 0.0;
    
    for (var expense in upcomingFixedExpenses) {
      totalCommittedObligations += (expense['amount'] as num).toDouble();
    }
    
    final safeZone = currentRawBankBalance - totalCommittedObligations;
    return safeZone < 0 ? 0.0 : safeZone;
  }

  /// Evaluates historical consumption patterns to estimate operational cash durability.
  /// Equation: Runway Days = Current Balance / (Total Past 30 Days Outflows / 30)
  static int calculateCashRunwayDays({
    required double currentLiquidCash,
    required double totalOutflowsPastMonth,
  }) {
    // If there is zero outbound activity logged, the runway duration is mathematically infinite
    if (totalOutflowsPastMonth <= 0) return 999; 
    
    final double dailyBurnRate = totalOutflowsPastMonth / 30.0;
    final int remainingDays = (currentLiquidCash / dailyBurnRate).floor();
    
    return remainingDays > 999 ? 999 : remainingDays;
  }

  /// Automated matching helper to identify potential debt payouts.
  /// Checks if an incoming sender identity closely matches an outstanding debtor account name.
  static List<Map<String, dynamic>> matchIncomingDepositsToDebtors({
    required List<TransactionModel> unlinkedDeposits,
    required List<Map<String, dynamic>> activeDebtors,
  }) {
    List<Map<String, dynamic>> automatedSuggestions = [];

    for (var deposit in unlinkedDeposits) {
      final String parsedName = deposit.depositorName.toUpperCase().trim();
      
      for (var debtor in activeDebtors) {
        final String targetClientName = (debtor['client_name'] as String).toUpperCase().trim();
        final double outstandingBalance = (debtor['total_debt'] as num).toDouble();

        // Direct matching optimization flag: exact hit or matching transactional volume
        if (parsedName.contains(targetClientName) || 
            targetClientName.contains(parsedName) || 
            (deposit.amount == outstandingBalance && parsedName != 'UNKNOWN')) {
          
          automatedSuggestions.add({
            'transaction_reference': deposit.referenceNumber,
            'debtor_id': debtor['id'],
            'client_name': debtor['client_name'],
            'amount': deposit.amount,
            'confidence_match': parsedName == targetClientName ? 'HIGH' : 'MEDIUM',
          });
        }
      }
    }

    return automatedSuggestions;
  }
}