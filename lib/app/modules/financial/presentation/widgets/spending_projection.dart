import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';

class SpendingProjection extends StatelessWidget {
  final List<TransactionModel> transactions;

  const SpendingProjection({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final monthlyExpenses = _getMonthlyExpenses();
    final avgExpense = monthlyExpenses.isEmpty
        ? 0.0
        : monthlyExpenses.reduce((a, b) => a + b) / monthlyExpenses.length;

    final currentDay = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - currentDay;

    final currentMonthExpenses = _getCurrentMonthExpenses();
    final projectedTotal = _calculateProjection(monthlyExpenses, now.month);

    final dailyAverage =
        currentMonthExpenses / (currentDay == 0 ? 1 : currentDay);
    final projectedEndOfMonth = dailyAverage * daysInMonth;

    final maxExpense = monthlyExpenses.isEmpty
        ? 0.0
        : monthlyExpenses.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Projeção de Gastos',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProjectionCard(
                  'Média Histórica',
                  currencyFormat.format(avgExpense),
                  'Baseado nos últimos ${monthlyExpenses.length} meses',
                  Icons.history,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProjectionCard(
                  'Projeção Atual',
                  currencyFormat.format(projectedEndOfMonth),
                  'Baseado no gasto diário atual',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProjectionCard(
                  'Maior Gasto',
                  currencyFormat.format(maxExpense),
                  'Maior despesa mensal registrada',
                  Icons.arrow_upward,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Você tem $daysRemaining dias restantes no mês. '
                    'Com o ritmo atual,预计本月支出: ${currencyFormat.format(projectedEndOfMonth)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getMonthlyExpenses() {
    final monthlyTotals = <int, double>{};

    for (var t in transactions.where(
      (t) => t.type == TransactionTypeModel.expense,
    )) {
      final monthKey = t.date.year * 12 + t.date.month;
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + t.amount;
    }

    final sortedKeys = monthlyTotals.keys.toList()..sort();
    final last6Months = sortedKeys.length > 6
        ? sortedKeys.sublist(sortedKeys.length - 6)
        : sortedKeys;

    return last6Months.map((k) => monthlyTotals[k]!).toList();
  }

  double _getCurrentMonthExpenses() {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.type == TransactionTypeModel.expense &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateProjection(List<double> monthlyExpenses, int currentMonth) {
    if (monthlyExpenses.isEmpty) return 0.0;

    final currentDay = DateTime.now().day;
    final daysInMonth = DateTime(DateTime.now().year, currentMonth + 1, 0).day;

    final currentExpenses = _getCurrentMonthExpenses();
    final dailyAverage = currentExpenses / (currentDay == 0 ? 1 : currentDay);

    return dailyAverage * daysInMonth;
  }

  Widget _buildProjectionCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
