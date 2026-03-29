import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/goal_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';

class GoalsPanel extends StatelessWidget {
  final List<GoalModel> goals;
  final VoidCallback onRefresh;

  const GoalsPanel({super.key, required this.goals, required this.onRefresh});

  double get _totalSaved => goals.fold(0.0, (sum, g) => sum + g.currentAmount);
  double get _totalTarget => goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  @override
  Widget build(BuildContext context) {
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
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Economizado',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'R\$ ${_totalSaved.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Meta total: R\$ ${_totalTarget.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddGoalDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Meta'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: goals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma meta definida',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _showAddGoalDialog(context),
                              child: const Text('Criar primeira meta'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.5,
                            ),
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          return _GoalCard(
                            goal: goals[index],
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

  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 30));
    Color selectedColor = AppTheme.primaryColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nova Meta'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome da Meta'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor Meta',
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data Limite'),
                  subtitle: Text(
                    '${targetDate.day}/${targetDate.month}/${targetDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() => targetDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Cor'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      [
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                            Colors.red,
                            Colors.teal,
                            Colors.pink,
                            Colors.amber,
                          ]
                          .map(
                            (c) => GestureDetector(
                              onTap: () => setState(() => selectedColor = c),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: selectedColor == c
                                      ? Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          )
                          .toList(),
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
                if (nameController.text.isNotEmpty &&
                    targetController.text.isNotEmpty) {
                  final goal = GoalModel(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    targetAmount: double.tryParse(targetController.text) ?? 0,
                    targetDate: targetDate,
                    createdAt: DateTime.now(),
                    color: selectedColor.value,
                  );
                  await DatabaseService.goals.put(goal.id, goal);
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
}

class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onRefresh;

  const _GoalCard({required this.goal, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isCompleted = goal.isCompleted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: isCompleted ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(goal.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'add', child: Text('Adicionar')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'add') {
                      _showAddAmountDialog(context);
                    } else if (value == 'delete') {
                      await DatabaseService.goals.delete(goal.id);
                      onRefresh();
                    }
                  },
                ),
            ],
          ),
          const Spacer(),
          Text(
            'R\$ ${goal.currentAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(goal.color),
            ),
          ),
          Text(
            'de R\$ ${goal.targetAmount.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Color(goal.color)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCompleted ? 'Meta alcançada!' : '$daysLeft dias restantes',
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAmountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Valor'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valor',
            prefixText: 'R\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                goal.currentAmount += amount;
                if (goal.currentAmount >= goal.targetAmount) {
                  goal.isCompleted = true;
                }
                await DatabaseService.goals.put(goal.id, goal);
                Navigator.pop(context);
                onRefresh();
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
