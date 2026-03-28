import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';

class BudgetPanel extends StatelessWidget {
  final List<TransactionModel> transactions;
  final VoidCallback onRefresh;

  const BudgetPanel({
    super.key,
    required this.transactions,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final budgets = DatabaseService.budgets.values
        .where((b) => b.month == now.month && b.year == now.year)
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 32,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Orçamentos este mês',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${budgets.length} categorias orçadas',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddBudgetDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Meta'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: budgets.isEmpty
                    ? _buildEmptyState(context)
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2,
                            ),
                        itemCount: budgets.length,
                        itemBuilder: (context, index) {
                          return _BudgetCard(
                            budget: budgets[index],
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
          Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhum orçamento definido',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showAddBudgetDialog(context),
            child: const Text('Criar orçamento'),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final nameController = TextEditingController();
    final limitController = TextEditingController();
    String selectedCategory = 'food';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Novo Orçamento'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: TransactionCategoryModel.values
                      .where(
                        (c) =>
                            c != TransactionCategoryModel.salary &&
                            c != TransactionCategoryModel.investment,
                      )
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.name,
                          child: Text(_getCategoryName(c)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: limitController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Limite mensal',
                    prefixText: 'R\$ ',
                  ),
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
                final now = DateTime.now();
                final budget = BudgetModel(
                  id: const Uuid().v4(),
                  category: selectedCategory,
                  limitAmount: double.tryParse(limitController.text) ?? 0,
                  month: now.month,
                  year: now.year,
                );
                await DatabaseService.budgets.put(budget.id, budget);
                Navigator.pop(context);
                onRefresh();
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
      default:
        return category.name;
    }
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback onRefresh;

  const _BudgetCard({required this.budget, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isOver = budget.isOverBudget;
    final color = isOver ? Colors.red : _getCategoryColor(budget.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOver ? Border.all(color: Colors.red, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getCategoryIcon(budget.category), color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getCategoryName(budget.category),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
                onSelected: (value) async {
                  if (value == 'delete') {
                    await DatabaseService.budgets.delete(budget.id);
                    onRefresh();
                  }
                },
              ),
            ],
          ),
          const Spacer(),
          Text(
            'R\$ ${budget.spentAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isOver ? Colors.red : null,
            ),
          ),
          Text(
            'de R\$ ${budget.limitAmount.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: budget.progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(isOver ? Colors.red : color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.teal;
      case 'shopping':
        return Colors.amber;
      case 'bills':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt_long;
      default:
        return Icons.more_horiz;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'food':
        return 'Alimentação';
      case 'transport':
        return 'Transporte';
      case 'entertainment':
        return 'Entretenimento';
      case 'health':
        return 'Saúde';
      case 'education':
        return 'Educação';
      case 'shopping':
        return 'Compras';
      case 'bills':
        return 'Contas';
      default:
        return 'Outros';
    }
  }
}
