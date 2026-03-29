import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/debt_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';

class RemindersDebtsPanel extends StatefulWidget {
  final VoidCallback onRefresh;

  const RemindersDebtsPanel({super.key, required this.onRefresh});

  @override
  State<RemindersDebtsPanel> createState() => _RemindersDebtsPanelState();
}

class _RemindersDebtsPanelState extends State<RemindersDebtsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Contas a Pagar', icon: Icon(Icons.warning_amber)),
              Tab(text: 'Dívidas', icon: Icon(Icons.swap_horiz)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildRemindersTab(), _buildDebtsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersTab() {
    final reminders = DatabaseService.reminders.values.toList();
    final overdue = reminders.where((r) => r.isOverdue).toList();
    final dueSoon = reminders
        .where((r) => r.isDueSoon && !r.isOverdue)
        .toList();
    final upcoming = reminders
        .where((r) => !r.isOverdue && !r.isDueSoon)
        .toList();
    final paid = reminders.where((r) => r.isPaid).toList();

    final totalPending = reminders
        .where((r) => !r.isPaid)
        .fold(0.0, (sum, r) => sum + r.amount);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pendente',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${totalPending.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reminders.where((r) => !r.isPaid).length} abertas',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  _buildQuickStat(
                    'Atrasadas',
                    overdue.length.toString(),
                    Icons.warning,
                    Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _buildQuickStat(
                    'Vencem Soon',
                    dueSoon.length.toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddReminderDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nova Conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (overdue.isNotEmpty) ...[
            _buildSectionHeader('Atrasadas', overdue.length, Colors.red),
            ...overdue.map((r) => _buildReminderCard(r)),
            const SizedBox(height: 16),
          ],
          if (dueSoon.isNotEmpty) ...[
            _buildSectionHeader(
              'Vencem em breve',
              dueSoon.length,
              Colors.orange,
            ),
            ...dueSoon.map((r) => _buildReminderCard(r)),
            const SizedBox(height: 16),
          ],
          if (upcoming.isNotEmpty) ...[
            _buildSectionHeader('Próximas', upcoming.length, Colors.blue),
            ...upcoming.map((r) => _buildReminderCard(r)),
            const SizedBox(height: 16),
          ],
          if (paid.isNotEmpty) ...[
            _buildSectionHeader('Pagas', paid.length, Colors.green),
            ...paid.map((r) => _buildReminderCard(r, isPaid: true)),
          ],
          if (reminders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma conta cadastrada',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder, {bool isPaid = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: reminder.isPaid,
          onChanged: (value) async {
            reminder.isPaid = value ?? false;
            await DatabaseService.reminders.put(reminder.id, reminder);
            widget.onRefresh();
          },
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            decoration: reminder.isPaid ? TextDecoration.lineThrough : null,
            color: reminder.isPaid ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          'Venc: ${reminder.dueDate.day}/${reminder.dueDate.month}/${reminder.dueDate.year}',
          style: TextStyle(
            color: reminder.isOverdue ? Colors.red : Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'R\$ ${reminder.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPaid
                    ? Colors.green
                    : (reminder.isOverdue ? Colors.red : Colors.black),
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'delete', child: Text('Excluir')),
              ],
              onSelected: (value) async {
                if (value == 'delete') {
                  await DatabaseService.reminders.delete(reminder.id);
                  widget.onRefresh();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtsTab() {
    final debts = DatabaseService.debts.values.toList();
    final owedToMe = debts
        .where((d) => d.type == DebtType.owedToMe && !d.isPaid)
        .toList();
    final iOwe = debts
        .where((d) => d.type == DebtType.iOwe && !d.isPaid)
        .toList();
    final paid = debts.where((d) => d.isPaid).toList();

    final totalOwedToMe = owedToMe.fold(0.0, (sum, d) => sum + d.amount);
    final totalIOwe = iOwe.fold(0.0, (sum, d) => sum + d.amount);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.green),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${totalOwedToMe.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      const Text('A Receber', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${totalIOwe.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                      const Text('A Pagar', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddDebtDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Novo'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (owedToMe.isNotEmpty) ...[
            _buildDebtSection('Que me devem', owedToMe, Colors.green),
          ],
          if (iOwe.isNotEmpty) ...[
            _buildDebtSection('Que devo', iOwe, Colors.red),
          ],
          if (paid.isNotEmpty) ...[
            _buildDebtSection('Quitados', paid, Colors.grey),
          ],
          if (debts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma dívida cadastrada',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDebtSection(String title, List<DebtModel> debts, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 8),
        ...debts.map(
          (d) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(
                  d.type == DebtType.owedToMe
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(d.personName),
              subtitle: d.description != null
                  ? Text(d.description!, style: const TextStyle(fontSize: 12))
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'R\$ ${d.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  if (!d.isPaid)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () async {
                        d.isPaid = true;
                        await DatabaseService.debts.put(d.id, d);
                        widget.onRefresh();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nova Conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nome da Conta'),
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vencimento'),
                subtitle: Text(
                  '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => dueDate = picked);
                },
              ),
            ],
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
                  final reminder = ReminderModel(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    amount: double.tryParse(amountController.text) ?? 0,
                    dueDate: dueDate,
                    type: ReminderType.bill,
                    createdAt: DateTime.now(),
                  );
                  await DatabaseService.reminders.put(reminder.id, reminder);
                  Navigator.pop(context);
                  widget.onRefresh();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDebtDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descController = TextEditingController();
    DebtType type = DebtType.iOwe;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nova Dívida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Eu devo'),
                      selected: type == DebtType.iOwe,
                      onSelected: (_) => setState(() => type = DebtType.iOwe),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Me devem'),
                      selected: type == DebtType.owedToMe,
                      onSelected: (_) =>
                          setState(() => type = DebtType.owedToMe),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: type == DebtType.iOwe
                      ? 'Para quem devo?'
                      : 'Quem me deve?',
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
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Observação (opcional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  final debt = DebtModel(
                    id: const Uuid().v4(),
                    personName: nameController.text,
                    amount: double.tryParse(amountController.text) ?? 0,
                    description: descController.text.isEmpty
                        ? null
                        : descController.text,
                    type: type,
                    createdAt: DateTime.now(),
                  );
                  await DatabaseService.debts.put(debt.id, debt);
                  Navigator.pop(context);
                  widget.onRefresh();
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
