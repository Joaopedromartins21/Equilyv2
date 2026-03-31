import 'package:flutter/material.dart';
import '../../app/modules/financial/data/models/transaction_model.dart';

class CategoryHelper {
  static Color getColor(TransactionCategoryModel category) {
    switch (category) {
      case TransactionCategoryModel.salary:
        return Colors.blue;
      case TransactionCategoryModel.investment:
        return Colors.green;
      case TransactionCategoryModel.food:
        return Colors.orange;
      case TransactionCategoryModel.transport:
        return Colors.purple;
      case TransactionCategoryModel.entertainment:
        return Colors.pink;
      case TransactionCategoryModel.health:
        return Colors.red;
      case TransactionCategoryModel.education:
        return Colors.teal;
      case TransactionCategoryModel.shopping:
        return Colors.amber;
      case TransactionCategoryModel.bills:
        return Colors.brown;
      case TransactionCategoryModel.other:
        return Colors.grey;
    }
  }

  static String getName(TransactionCategoryModel category) {
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

  static IconData getIcon(TransactionCategoryModel category) {
    switch (category) {
      case TransactionCategoryModel.salary:
        return Icons.work;
      case TransactionCategoryModel.investment:
        return Icons.trending_up;
      case TransactionCategoryModel.food:
        return Icons.restaurant;
      case TransactionCategoryModel.transport:
        return Icons.directions_car;
      case TransactionCategoryModel.entertainment:
        return Icons.movie;
      case TransactionCategoryModel.health:
        return Icons.local_hospital;
      case TransactionCategoryModel.education:
        return Icons.school;
      case TransactionCategoryModel.shopping:
        return Icons.shopping_bag;
      case TransactionCategoryModel.bills:
        return Icons.receipt;
      case TransactionCategoryModel.other:
        return Icons.more_horiz;
    }
  }

  static List<TransactionCategoryModel> getExpenseCategories() {
    return [
      TransactionCategoryModel.food,
      TransactionCategoryModel.transport,
      TransactionCategoryModel.entertainment,
      TransactionCategoryModel.health,
      TransactionCategoryModel.education,
      TransactionCategoryModel.shopping,
      TransactionCategoryModel.bills,
      TransactionCategoryModel.other,
    ];
  }

  static List<TransactionCategoryModel> getIncomeCategories() {
    return [
      TransactionCategoryModel.salary,
      TransactionCategoryModel.investment,
      TransactionCategoryModel.other,
    ];
  }

  static List<TransactionCategoryModel> getCategoriesByType(
    TransactionTypeModel type,
  ) {
    return type == TransactionTypeModel.income
        ? getIncomeCategories()
        : getExpenseCategories();
  }
}

class MonthSelector extends StatefulWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedMonth;
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    widget.onMonthChanged(_currentMonth);
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        _currentMonth = nextMonth;
      });
      widget.onMonthChanged(_currentMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canGoNext = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
    ).isBefore(DateTime(now.year, now.month + 1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: _previousMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _currentMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year, now.month + 1),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                setState(() {
                  _currentMonth = DateTime(picked.year, picked.month);
                });
                widget.onMonthChanged(_currentMonth);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _formatMonth(_currentMonth),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: 20,
              color: canGoNext ? null : Colors.grey,
            ),
            onPressed: canGoNext ? _nextMonth : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
