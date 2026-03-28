import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/account_model.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';

class AccountsPanel extends StatelessWidget {
  final List<AccountModel> accounts;
  final VoidCallback onRefresh;

  const AccountsPanel({
    super.key,
    required this.accounts,
    required this.onRefresh,
  });

  double get _totalBalance => accounts.fold(0.0, (sum, a) => sum + a.balance);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF8B7CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo Total',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${_totalBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${accounts.length} contas cadastradas',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddAccountDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Conta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return _AccountCard(
                        account: account,
                        onRefresh: onRefresh,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo por Tipo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTypeSummary(
                  'Conta Corrente',
                  accounts
                      .where((a) => a.type == 'checking')
                      .fold(0.0, (s, a) => s + a.balance),
                  Colors.blue,
                ),
                _buildTypeSummary(
                  'Poupança',
                  accounts
                      .where((a) => a.type == 'savings')
                      .fold(0.0, (s, a) => s + a.balance),
                  Colors.green,
                ),
                _buildTypeSummary(
                  'Cartão',
                  accounts
                      .where((a) => a.type == 'credit')
                      .fold(0.0, (s, a) => s + a.balance),
                  Colors.orange,
                ),
                _buildTypeSummary(
                  'Dinheiro',
                  accounts
                      .where((a) => a.type == 'cash')
                      .fold(0.0, (s, a) => s + a.balance),
                  Colors.purple,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Fatura do Cartão',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildCreditCardInvoice(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardInvoice() {
    final now = DateTime.now();
    final creditTransactions = DatabaseService.transactions.values
        .where(
          (t) =>
              t.type == TransactionTypeModel.expense &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .toList();

    final total = creditTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final creditAccounts = accounts.where((a) => a.type == 'credit').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Fatura ${_getMonthName(now.month)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${creditTransactions.length} transações no mês',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        if (creditAccounts.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Meus Cartões',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...creditAccounts.map((card) => _buildCreditCardItem(card)),
        ],
      ],
    );
  }

  Widget _buildCreditCardItem(AccountModel card) {
    final now = DateTime.now();
    final cardTransactions = DatabaseService.transactions.values
        .where(
          (t) =>
              t.accountId == card.id &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .toList();
    final spent = cardTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final available = card.creditLimit != null
        ? card.creditLimit! - spent
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(card.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.credit_card, color: Color(card.color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (card.dueDay != null)
                  Text(
                    'Vencimento: ${card.dueDay}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${spent.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (available != null)
                Text(
                  'Disp: R\$ ${available.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  Widget _buildTypeSummary(String type, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(type)),
          Text(
            'R\$ ${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    final limitController = TextEditingController();
    final dueDayController = TextEditingController();
    String selectedType = 'checking';
    Color selectedColor = AppTheme.primaryColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nova Conta'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Conta',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(
                        value: 'checking',
                        child: Text('Conta Corrente'),
                      ),
                      DropdownMenuItem(
                        value: 'savings',
                        child: Text('Poupança'),
                      ),
                      DropdownMenuItem(
                        value: 'credit',
                        child: Text('Cartão de Crédito'),
                      ),
                      DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
                    ],
                    onChanged: (v) => setState(() => selectedType = v!),
                  ),
                  const SizedBox(height: 16),
                  if (selectedType == 'credit') ...[
                    TextField(
                      controller: limitController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Limite do Cartão',
                        prefixText: 'R\$ ',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dueDayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Dia de Vencimento',
                        hintText: 'Ex: 15',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Saldo Inicial',
                        prefixText: 'R\$ ',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('Cor'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                              Colors.indigo,
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final account = AccountModel(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    balance: selectedType == 'credit'
                        ? 0
                        : (double.tryParse(balanceController.text) ?? 0),
                    color: selectedColor.value,
                    type: selectedType,
                    creditLimit: selectedType == 'credit'
                        ? (double.tryParse(limitController.text) ?? 0)
                        : null,
                    dueDay: selectedType == 'credit'
                        ? (int.tryParse(dueDayController.text) ?? 15)
                        : null,
                  );
                  await DatabaseService.accounts.put(account.id, account);
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

class _AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback onRefresh;

  const _AccountCard({required this.account, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(account.color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getAccountIcon(), color: Color(account.color)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _getAccountTypeName(),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  if (account.isCreditCard && account.creditLimit != null)
                    Text(
                      'Limite: R\$ ${account.creditLimit!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${account.balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: account.isCreditCard
                        ? (account.balance > 0
                              ? AppTheme.errorColor
                              : AppTheme.textPrimary)
                        : (account.balance >= 0
                              ? AppTheme.secondaryColor
                              : AppTheme.errorColor),
                  ),
                ),
                Text(
                  account.isCreditCard
                      ? (account.balance > 0 ? 'gasto' : 'livre')
                      : account.currency,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                if (account.isCreditCard && account.dueDay != null)
                  Text(
                    'Vence: ${account.dueDay}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Excluir')),
              ],
              onSelected: (value) async {
                if (value == 'delete') {
                  await DatabaseService.accounts.delete(account.id);
                  onRefresh();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountIcon() {
    switch (account.type) {
      case 'checking':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'credit':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _getAccountTypeName() {
    switch (account.type) {
      case 'checking':
        return 'Conta Corrente';
      case 'savings':
        return 'Poupança';
      case 'credit':
        return 'Cartão de Crédito';
      case 'cash':
        return 'Dinheiro';
      default:
        return 'Conta';
    }
  }
}
