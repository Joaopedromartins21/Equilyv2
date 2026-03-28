import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/recurring_model.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';

class RecurringPanel extends StatelessWidget {
  final VoidCallback onRefresh;

  const RecurringPanel({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final recurring = DatabaseService.recurring.values.toList();
    final monthlyTotal = recurring
        .where((r) => r.isActive && r.type == 'expense')
        .fold(0.0, (sum, r) => sum + r.amount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Color(0xFFFF8C42)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gastos Fixos Mensais',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${monthlyTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${recurring.where((r) => r.isActive).length} transações ativas',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddRecurringDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Gasto Fixo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: recurring.isEmpty
                    ? _buildEmptyState(context)
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.2,
                            ),
                        itemCount: recurring.length,
                        itemBuilder: (context, index) {
                          return _RecurringCard(
                            recurring: recurring[index],
                            onRefresh: onRefresh,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.repeat, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhum gasto fixo cadastrado',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showAddRecurringDialog(context),
            child: const Text('Cadastrar primeiro gasto'),
          ),
        ],
      ),
    );
  }

  void _showAddRecurringDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    TransactionCategoryModel category = TransactionCategoryModel.bills;
    RecurrenceType recurrence = RecurrenceType.monthly;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Novo Gasto Fixo'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Ex: Netflix, Aluguel, Luz',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TransactionCategoryModel>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: TransactionCategoryModel.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(_getCategoryName(c)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => category = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RecurrenceType>(
                  value: recurrence,
                  decoration: const InputDecoration(labelText: 'Frequência'),
                  items: RecurrenceType.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(_getRecurrenceName(r)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => recurrence = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  final recurring = RecurringTransactionModel(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    amount: double.tryParse(amountController.text) ?? 0,
                    category: category.name,
                    type: 'expense',
                    recurrence: recurrence,
                    startDate: DateTime.now(),
                  );
                  await DatabaseService.recurring.put(recurring.id, recurring);
                  Navigator.pop(context);
                  onRefresh();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(TransactionCategoryModel category) {
    switch (category) {
      case TransactionCategoryModel.bills:
        return 'Contas';
      case TransactionCategoryModel.entertainment:
        return 'Entretenimento';
      case TransactionCategoryModel.transport:
        return 'Transporte';
      case TransactionCategoryModel.health:
        return 'Saúde';
      case TransactionCategoryModel.education:
        return 'Educação';
      case TransactionCategoryModel.shopping:
        return 'Compras';
      case TransactionCategoryModel.food:
        return 'Alimentação';
      default:
        return 'Outros';
    }
  }

  String _getRecurrenceName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Diário';
      case RecurrenceType.weekly:
        return 'Semanal';
      case RecurrenceType.monthly:
        return 'Mensal';
      case RecurrenceType.yearly:
        return 'Anual';
    }
  }
}

class _RecurringCard extends StatelessWidget {
  final RecurringTransactionModel recurring;
  final VoidCallback onRefresh;

  const _RecurringCard({required this.recurring, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: recurring.isActive
            ? null
            : Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: _getCategoryColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recurring.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: recurring.isActive
                        ? null
                        : TextDecoration.lineThrough,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Switch(
                value: recurring.isActive,
                onChanged: (value) async {
                  recurring.isActive = value;
                  await DatabaseService.recurring.put(recurring.id, recurring);
                  onRefresh();
                },
              ),
            ],
          ),
          const Spacer(),
          Text(
            'R\$ ${recurring.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Icon(Icons.repeat, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                _getRecurrenceName(),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const Spacer(),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'process',
                    child: Text('Lançar agora'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
                onSelected: (value) async {
                  if (value == 'process') {
                    await _processNow();
                  } else if (value == 'delete') {
                    await DatabaseService.recurring.delete(recurring.id);
                    onRefresh();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _processNow() async {
    final transaction = TransactionModel(
      id: const Uuid().v4(),
      title: recurring.title,
      amount: recurring.amount,
      type: TransactionTypeModel.expense,
      category: TransactionCategoryModel.values.firstWhere(
        (c) => c.name == recurring.category,
        orElse: () => TransactionCategoryModel.other,
      ),
      date: DateTime.now(),
      accountId: 'default',
    );
    await DatabaseService.transactions.put(transaction.id, transaction);
    recurring.lastProcessed = DateTime.now();
    await DatabaseService.recurring.put(recurring.id, recurring);
    onRefresh();
  }

  Color _getCategoryColor() {
    switch (recurring.category) {
      case 'bills':
        return Colors.brown;
      case 'entertainment':
        return Colors.pink;
      case 'transport':
        return Colors.purple;
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.teal;
      case 'shopping':
        return Colors.amber;
      case 'food':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (recurring.category) {
      case 'bills':
        return Icons.receipt_long;
      case 'entertainment':
        return Icons.movie;
      case 'transport':
        return Icons.directions_car;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_bag;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.more_horiz;
    }
  }

  String _getRecurrenceName() {
    switch (recurring.recurrence) {
      case RecurrenceType.daily:
        return 'Diário';
      case RecurrenceType.weekly:
        return 'Semanal';
      case RecurrenceType.monthly:
        return 'Mensal';
      case RecurrenceType.yearly:
        return 'Anual';
    }
  }
}
