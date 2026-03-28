import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';

class MonthlyChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const MonthlyChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final monthlyData = _getMonthlyData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Receitas x Despesas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: monthlyData.isEmpty
              ? const Center(child: Text('Sem dados suficientes'))
              : CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: _BarChartPainter(monthlyData),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Receitas', AppTheme.secondaryColor),
            const SizedBox(width: 24),
            _buildLegendItem('Despesas', AppTheme.errorColor),
          ],
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getMonthlyData() {
    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthTransactions = transactions.where(
        (t) => t.date.year == month.year && t.date.month == month.month,
      );

      final income = monthTransactions
          .where((t) => t.type == TransactionTypeModel.income)
          .fold(0.0, (sum, t) => sum + t.amount);

      final expense = monthTransactions
          .where((t) => t.type == TransactionTypeModel.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      data.add({'month': month, 'income': income, 'expense': expense});
    }

    return data;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  _BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.fold<double>(0, (max, d) {
      final m = (d['income'] as double) > (d['expense'] as double)
          ? d['income'] as double
          : d['expense'] as double;
      return m > max ? m : max;
    });

    if (maxValue == 0) return;

    final barWidth = (size.width - 60) / data.length / 3;
    final bottomPadding = 30.0;
    final chartHeight = size.height - bottomPadding;

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final income = d['income'] as double;
      final expense = d['expense'] as double;

      final x = 40 + (i * (size.width - 40) / data.length);

      final incomeHeight = (income / maxValue) * chartHeight;
      final expenseHeight = (expense / maxValue) * chartHeight;

      final monthNames = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      final month = d['month'] as DateTime;

      final textPainter = TextPainter(
        text: TextSpan(
          text: monthNames[month.month - 1],
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 20),
      );

      if (incomeHeight > 0) {
        final paint = Paint()
          ..color = AppTheme.secondaryColor
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x,
              chartHeight - incomeHeight,
              barWidth,
              incomeHeight,
            ),
            const Radius.circular(4),
          ),
          paint,
        );
      }

      if (expenseHeight > 0) {
        final paint = Paint()
          ..color = AppTheme.errorColor
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x + barWidth + 4,
              chartHeight - expenseHeight,
              barWidth,
              expenseHeight,
            ),
            const Radius.circular(4),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
