import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';
import '../../../financial/data/models/transaction_model.dart';
import '../../../financial/data/models/debt_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = DatabaseService.transactions.values.toList();
    final accounts = DatabaseService.accounts.values.toList();
    final goals = DatabaseService.goals.values.toList();
    final reminders = DatabaseService.reminders.values
        .where((r) => !r.isPaid)
        .toList();
    final debts = DatabaseService.debts.values.where((d) => !d.isPaid).toList();

    final totalIncome = transactions
        .where((t) => t.type == TransactionTypeModel.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionTypeModel.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;
    final totalBalance = accounts.fold(0.0, (sum, a) => sum + a.balance);
    final totalGoals = goals.fold(0.0, (sum, g) => sum + g.currentAmount);
    final totalGoalTarget = goals.fold(0.0, (sum, g) => sum + g.targetAmount);
    final totalReceber = debts
        .where((d) => d.type == DebtType.owedToMe)
        .fold(0.0, (sum, d) => sum + d.amount);
    final totalPagar = debts
        .where((d) => d.type == DebtType.iOwe)
        .fold(0.0, (sum, d) => sum + d.amount);

    final now = DateTime.now();
    final thisMonthTransactions = transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();
    final monthIncome = thisMonthTransactions
        .where((t) => t.type == TransactionTypeModel.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final monthExpense = thisMonthTransactions
        .where((t) => t.type == TransactionTypeModel.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Visão geral das suas finanças',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 90,
              child: Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      'Saldo Total',
                      'R\$ ${totalBalance.toStringAsFixed(2)}',
                      Icons.account_balance_wallet,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard(
                      'Receitas',
                      'R\$ ${monthIncome.toStringAsFixed(2)}',
                      Icons.arrow_downward,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard(
                      'Despesas',
                      'R\$ ${monthExpense.toStringAsFixed(2)}',
                      Icons.arrow_upward,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard(
                      'Este Mês',
                      'R\$ ${(monthIncome - monthExpense).toStringAsFixed(2)}',
                      Icons.trending_up,
                      (monthIncome - monthExpense) >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildSection(
                        'Metas de Economia',
                        Icons.flag,
                        Colors.green,
                        goals.isEmpty
                            ? 'Nenhuma meta definida'
                            : '${goals.where((g) => g.isCompleted).length}/${goals.length} concluídas',
                      ),
                      if (goals.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...goals.take(3).map((g) => _buildGoalProgress(g)),
                      ],
                      const SizedBox(height: 16),
                      _buildSection(
                        'Contas Pendentes',
                        Icons.warning_amber,
                        Colors.orange,
                        '${reminders.length} contas a pagar',
                      ),
                      if (reminders.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...reminders.take(3).map((r) => _buildReminderItem(r)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildSection(
                        'Dividas',
                        Icons.swap_horiz,
                        Colors.purple,
                        '',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDebtCard(
                              'A Receber',
                              totalReceber,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDebtCard(
                              'A Pagar',
                              totalPagar,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        'Resumo do Mês',
                        Icons.calendar_today,
                        Colors.blue,
                        '',
                      ),
                      const SizedBox(height: 12),
                      _buildMonthSummary(monthIncome, monthExpense),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress(dynamic goal) {
    final progress = goal.progress;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: Color(goal.color),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Color(goal.color)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${goal.currentAmount.toStringAsFixed(2)} / R\$ ${goal.targetAmount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(dynamic reminder) {
    final isOverdue = reminder.isOverdue;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (isOverdue ? Colors.red : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.schedule,
            color: isOverdue ? Colors.red : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(reminder.title, style: const TextStyle(fontSize: 12)),
          ),
          Text(
            'R\$ ${reminder.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Icon(
            title == 'A Receber' ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: color, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(double income, double expense) {
    final balance = income - expense;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: balance >= 0
              ? [Colors.green, const Color(0xFF00C9A7)]
              : [Colors.red, Colors.orange],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            balance >= 0 ? 'Sobrou!' : 'Gastou demais!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${balance.abs().toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'Receitas',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    'R\$ ${income.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Despesas',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    'R\$ ${expense.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum DebtType { owedToMe, iOwe }
