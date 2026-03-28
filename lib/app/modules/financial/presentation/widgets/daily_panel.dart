import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/debt_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';

class DailyPanel extends StatelessWidget {
  final VoidCallback onRefresh;

  const DailyPanel({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final transactions = DatabaseService.transactions.values.toList();
    final reminders = DatabaseService.reminders.values.toList();
    final recurring = DatabaseService.recurring.values
        .where((r) => r.isActive)
        .toList();

    final todayTransactions = transactions
        .where(
          (t) =>
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day,
        )
        .toList();
    final tomorrowTransactions = transactions
        .where(
          (t) =>
              t.date.year == tomorrow.year &&
              t.date.month == tomorrow.month &&
              t.date.day == tomorrow.day,
        )
        .toList();

    final todayReminders = reminders
        .where(
          (r) =>
              r.dueDate.year == today.year &&
              r.dueDate.month == today.month &&
              r.dueDate.day == today.day &&
              !r.isPaid,
        )
        .toList();
    final upcomingReminders =
        reminders
            .where(
              (r) =>
                  r.dueDate.isAfter(today) &&
                  r.dueDate.isBefore(tomorrow.add(const Duration(days: 6))) &&
                  !r.isPaid,
            )
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final todayIncome = todayTransactions
        .where((t) => t.type == TransactionTypeModel.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final todayExpense = todayTransactions
        .where((t) => t.type == TransactionTypeModel.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final tomorrowIncome = tomorrowTransactions
        .where((t) => t.type == TransactionTypeModel.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final tomorrowExpense = tomorrowTransactions
        .where((t) => t.type == TransactionTypeModel.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalReceber = DatabaseService.debts.values
        .where((d) => d.type == DebtType.owedToMe && !d.isPaid)
        .fold(0.0, (sum, d) => sum + d.amount);
    final totalPagar = DatabaseService.debts.values
        .where((d) => d.type == DebtType.iOwe && !d.isPaid)
        .fold(0.0, (sum, d) => sum + d.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTodayCard(
                  todayIncome,
                  todayExpense,
                  todayReminders.length,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTomorrowCard(tomorrowIncome, tomorrowExpense),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildQuickStats(totalReceber, totalPagar)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildUpcomingBills(upcomingReminders)),
            ],
          ),
          const SizedBox(height: 24),
          if (todayTransactions.isNotEmpty) ...[
            const Text(
              'Movimentos de Hoje',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...todayTransactions.map((t) => _buildTransactionItem(t)),
          ],
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12)
      greeting = 'Bom dia';
    else if (hour < 18)
      greeting = 'Boa tarde';
    else
      greeting = 'Boa noite';

    final now = DateTime.now();
    final weekdays = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    final months = [
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(
          '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTodayCard(double income, double expense, int remindersCount) {
    final balance = income - expense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF8B7CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOJE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('Receita', income, Colors.greenAccent),
              const SizedBox(width: 16),
              _buildMiniStat('Despesa', expense, Colors.redAccent),
              const SizedBox(width: 16),
              if (remindersCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$remindersCount pendente${remindersCount > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
        Text(
          'R\$ ${value.toStringAsFixed(0)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTomorrowCard(double income, double expense) {
    final balance = income - expense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AMANHÃ',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: balance >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 14, color: Colors.green.shade400),
              const SizedBox(width: 4),
              Text(
                'R\$ ${income.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.green.shade400),
              ),
              const SizedBox(width: 16),
              Icon(Icons.arrow_downward, size: 14, color: Colors.red.shade400),
              const SizedBox(width: 4),
              Text(
                'R\$ ${expense.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(double receber, double pagar) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dívidas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A Receber',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'R\$ ${receber.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_upward, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A Pagar',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'R\$ ${pagar.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingBills(List<ReminderModel> reminders) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximas Contas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (reminders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Nenhuma conta próxima',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            ...reminders
                .take(5)
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: r.isOverdue
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${r.dueDate.day}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: r.isOverdue ? Colors.red : Colors.orange,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _getDayName(r.dueDate),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'R\$ ${r.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hoje';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Amanhã';

    final weekdays = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    return weekdays[date.weekday - 1];
  }

  Widget _buildTransactionItem(TransactionModel t) {
    final isIncome = t.type == TransactionTypeModel.income;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isIncome ? Colors.green : Colors.red).withValues(
            alpha: 0.1,
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(t.title),
        trailing: Text(
          '${isIncome ? '+' : '-'}R\$ ${t.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
