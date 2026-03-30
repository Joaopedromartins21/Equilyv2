import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';

class CategoryAlerts extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Map<TransactionCategoryModel, double>? categoryLimits;

  const CategoryAlerts({
    super.key,
    required this.transactions,
    this.categoryLimits,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final categoryTotals = <TransactionCategoryModel, double>{};
    for (var t in transactions.where(
      (t) =>
          t.type == TransactionTypeModel.expense &&
          t.date.year == now.year &&
          t.date.month == now.month,
    )) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final historicalAverages = _getHistoricalAverages();
    final alerts = <Map<String, dynamic>>[];

    for (var entry in categoryTotals.entries) {
      final current = entry.value;
      final average = historicalAverages[entry.key] ?? 0;

      if (average > 0) {
        final percentOver = ((current - average) / average) * 100;

        if (percentOver > 20) {
          alerts.add({
            'category': entry.key,
            'current': current,
            'average': average,
            'percent': percentOver,
            'type': percentOver > 50 ? 'danger' : 'warning',
          });
        }
      }

      final limit = categoryLimits?[entry.key];
      if (limit != null && current > limit) {
        final percentOver = ((current - limit) / limit) * 100;
        alerts.add({
          'category': entry.key,
          'current': current,
          'limit': limit,
          'percent': percentOver,
          'type': 'limit',
        });
      }
    }

    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nenhum alerta de gasto excessivo neste mês',
                style: TextStyle(fontSize: 13, color: Colors.green.shade700),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Alertas de Gastos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.map((alert) => _buildAlertItem(alert, currencyFormat)),
        ],
      ),
    );
  }

  Map<TransactionCategoryModel, double> _getHistoricalAverages() {
    final monthlyTotals = <TransactionCategoryModel, List<double>>{};

    for (var t in transactions.where(
      (t) => t.type == TransactionTypeModel.expense,
    )) {
      monthlyTotals.putIfAbsent(t.category, () => []);
      final monthKey = t.date.year * 12 + t.date.month;

      final existing = monthlyTotals[t.category]!;
      if (existing.isEmpty || _getMonthKey(existing.length) != monthKey) {
        monthlyTotals[t.category]!.add(t.amount);
      } else {
        monthlyTotals[t.category]![monthlyTotals[t.category]!.length - 1] +=
            t.amount;
      }
    }

    final averages = <TransactionCategoryModel, double>{};
    for (var entry in monthlyTotals.entries) {
      if (entry.value.isNotEmpty) {
        averages[entry.key] =
            entry.value.reduce((a, b) => a + b) / entry.value.length;
      }
    }

    return averages;
  }

  int _getMonthKey(int index) {
    final now = DateTime.now();
    return now.year * 12 + now.month - index;
  }

  Widget _buildAlertItem(
    Map<String, dynamic> alert,
    NumberFormat currencyFormat,
  ) {
    final categoryName = _getCategoryName(
      alert['category'] as TransactionCategoryModel,
    );
    final type = alert['type'] as String;

    String message;
    IconData icon;
    Color color;

    if (type == 'limit') {
      final limit = alert['limit'] as double;
      message =
          '$categoryName ultrapassou o limite de ${currencyFormat.format(limit)}';
      icon = Icons.block;
      color = Colors.red;
    } else {
      final percent = alert['percent'] as double;
      message =
          '$categoryName está ${percent.toStringAsFixed(0)}% acima da média';
      icon = Icons.trending_up;
      color = type == 'danger' ? Colors.red : Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 12, color: color)),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(TransactionCategoryModel category) {
    switch (category) {
      case TransactionCategoryModel.salary:
        return 'Salário';
      case TransactionCategoryModel.investment:
        return 'Investimento';
      case TransactionCategoryModel.food:
        return 'Alimentação';
      case TransactionCategoryModel.transport:
        return 'Transporte';
      case TransactionCategoryModel.entertainment:
        return 'Entretenimento';
      case TransactionCategoryModel.health:
        return 'Saúde';
      case TransactionCategoryModel.education:
        return 'Educação';
      case TransactionCategoryModel.shopping:
        return 'Compras';
      case TransactionCategoryModel.bills:
        return 'Contas';
      case TransactionCategoryModel.other:
        return 'Outros';
    }
  }
}
