import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/reminder_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';

class CalendarPanel extends StatefulWidget {
  final VoidCallback onRefresh;

  const CalendarPanel({super.key, required this.onRefresh});

  @override
  State<CalendarPanel> createState() => _CalendarPanelState();
}

class _CalendarPanelState extends State<CalendarPanel> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildMonthSelector(),
              const SizedBox(height: 16),
              _buildCalendarGrid(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(child: _buildDayDetails()),
      ],
    );
  }

  Widget _buildMonthSelector() {
    final months = [
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(
                () => _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                ),
              );
            },
          ),
          Expanded(
            child: Text(
              '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(
                () => _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;

    final transactions = DatabaseService.transactions.values.toList();
    final reminders = DatabaseService.reminders.values.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(6, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - startWeekday + 2;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 50));
                }
                final date = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month,
                  dayNumber,
                );
                final isToday =
                    date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;
                final isSelected =
                    date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;

                final dayTransactions = transactions
                    .where(
                      (t) =>
                          t.date.day == date.day &&
                          t.date.month == date.month &&
                          t.date.year == date.year,
                    )
                    .toList();
                final dayReminders = reminders
                    .where(
                      (r) =>
                          r.dueDate.day == date.day &&
                          r.dueDate.month == date.month &&
                          r.dueDate.year == date.year &&
                          !r.isPaid,
                    )
                    .toList();

                final hasExpense = dayTransactions.any(
                  (t) => t.type == TransactionTypeModel.expense,
                );
                final hasIncome = dayTransactions.any(
                  (t) => t.type == TransactionTypeModel.income,
                );

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : (isToday
                                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                  : null),
                        borderRadius: BorderRadius.circular(8),
                        border: isToday && !isSelected
                            ? Border.all(color: AppTheme.primaryColor)
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '$dayNumber',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isToday ? AppTheme.primaryColor : null),
                                fontWeight: isToday ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                          if (dayReminders.isNotEmpty)
                            Positioned(
                              bottom: 4,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          if (hasIncome || hasExpense)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasIncome)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.only(right: 2),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if (hasExpense)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayDetails() {
    final transactions = DatabaseService.transactions.values
        .where(
          (t) =>
              t.date.day == _selectedDate.day &&
              t.date.month == _selectedDate.month &&
              t.date.year == _selectedDate.year,
        )
        .toList();
    final reminders = DatabaseService.reminders.values
        .where(
          (r) =>
              r.dueDate.day == _selectedDate.day &&
              r.dueDate.month == _selectedDate.month &&
              r.dueDate.year == _selectedDate.year,
        )
        .toList();
    final recurring = DatabaseService.recurring.values
        .where(
          (r) =>
              r.startDate.day == _selectedDate.day &&
              r.startDate.month == _selectedDate.month,
        )
        .toList();

    final totalIncome = transactions
        .where((t) => t.type == TransactionTypeModel.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionTypeModel.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (totalExpense - totalIncome).abs() > 0
                    ? ((totalIncome - totalExpense) >= 0
                              ? Colors.green
                              : Colors.red)
                          .withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Receitas',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'R\$ ${totalIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Despesas',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'R\$ ${totalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (reminders.isNotEmpty) ...[
              const Text(
                'Contas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...reminders.map(
                (r) => Card(
                  color: r.isPaid
                      ? Colors.green.withValues(alpha: 0.1)
                      : (r.isOverdue
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1)),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      r.isPaid
                          ? Icons.check_circle
                          : (r.isOverdue ? Icons.warning : Icons.schedule),
                      color: r.isPaid
                          ? Colors.green
                          : (r.isOverdue ? Colors.red : Colors.orange),
                    ),
                    title: Text(r.title),
                    trailing: Text(
                      'R\$ ${r.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (transactions.isNotEmpty) ...[
              const Text(
                'Transações',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...transactions.map(
                (t) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    t.type == TransactionTypeModel.income
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: t.type == TransactionTypeModel.income
                        ? Colors.green
                        : Colors.red,
                    size: 20,
                  ),
                  title: Text(t.title, style: const TextStyle(fontSize: 14)),
                  trailing: Text(
                    '${t.type == TransactionTypeModel.income ? '+' : '-'}R\$ ${t.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: t.type == TransactionTypeModel.income
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            if (transactions.isEmpty && reminders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nada neste dia',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
