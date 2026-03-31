import 'package:flutter/material.dart';
import '../../../../../core/helpers/category_helper.dart';
import '../../data/models/transaction_model.dart';

class FinancialCharts extends StatelessWidget {
  final List<TransactionModel>? transactions;

  const FinancialCharts({super.key, this.transactions});

  @override
  Widget build(BuildContext context) {
    final expenses = _getExpensesByCategory();
    final total = expenses.fold<double>(
      0,
      (sum, e) => sum + (e['value'] as double),
    );

    if (expenses.isEmpty) {
      return const Center(child: Text('Sem dados suficientes'));
    }

    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            size: const Size(180, 180),
            painter: PieChartPainter(expenses, total),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(expenses),
      ],
    );
  }

  List<Map<String, dynamic>> _getExpensesByCategory() {
    final categories = <TransactionCategoryModel, double>{};
    for (var category in TransactionCategoryModel.values) {
      categories[category] = 0;
    }

    if (transactions != null) {
      for (var t in transactions!) {
        if (t.type == TransactionTypeModel.expense) {
          categories[t.category] = (categories[t.category] ?? 0) + t.amount;
        }
      }
    }

    return categories.entries
        .where((e) => e.value > 0)
        .map((e) => {'category': e.key, 'value': e.value})
        .toList();
  }

  Widget _buildLegend(List<Map<String, dynamic>> expenses) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: expenses.map((e) {
        final category = e['category'] as TransactionCategoryModel;
        return SizedBox(
          width: 100,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: CategoryHelper.getColor(category),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  CategoryHelper.getName(category),
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  PieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.brown,
      Colors.grey,
    ];

    double startAngle = -90 * (3.14159 / 180);
    int colorIndex = 0;

    for (var item in data) {
      final category = item['category'] as TransactionCategoryModel;
      final value = item['value'] as double;
      final sweepAngle = (value / total) * 360 * (3.14159 / 180);

      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.45, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
