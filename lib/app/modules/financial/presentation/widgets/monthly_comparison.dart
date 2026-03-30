import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';

class MonthlyComparison extends StatelessWidget {
  final List<TransactionModel> transactions;

  const MonthlyComparison({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    final currentMonthTransactions = transactions.where((t) {
      return t.date.year == currentMonth.year &&
          t.date.month == currentMonth.month;
    }).toList();

    final lastMonthTransactions = transactions.where((t) {
      return t.date.year == lastMonth.year && t.date.month == lastMonth.month;
    }).toList();

    final currentIncome = currentMonthTransactions
        .where((t) => t.type == TransactionTypeModel.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final currentExpense = currentMonthTransactions
        .where((t) => t.type == TransactionTypeModel.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final lastIncome = lastMonthTransactions
        .where((t) => t.type == TransactionTypeModel.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final lastExpense = lastMonthTransactions
        .where((t) => t.type == TransactionTypeModel.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final incomeDiff = currentIncome - lastIncome;
    final expenseDiff = currentExpense - lastExpense;
    final balanceDiff =
        (currentIncome - currentExpense) - (lastIncome - lastExpense);

    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

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
            'Comparativo Mensal',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  'Receitas',
                  currencyFormat.format(currentIncome),
                  currencyFormat.format(lastIncome),
                  incomeDiff,
                  lastIncome,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildComparisonCard(
                  'Despesas',
                  currencyFormat.format(currentExpense),
                  currencyFormat.format(lastExpense),
                  expenseDiff,
                  lastExpense,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildComparisonCard(
                  'Saldo',
                  currencyFormat.format(currentIncome - currentExpense),
                  currencyFormat.format(lastIncome - lastExpense),
                  balanceDiff,
                  lastIncome - lastExpense,
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    String title,
    String current,
    String last,
    double diff,
    double lastValue,
    Color color,
  ) {
    final isPositive = diff >= 0;
    final percentChange = lastValue != 0 ? (diff / lastValue.abs()) * 100 : 0.0;

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
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            current,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Mês anterior: $last',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                '${percentChange.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
