import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _installmentController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();
  TransactionTypeModel _type = TransactionTypeModel.expense;
  TransactionCategoryModel _category = TransactionCategoryModel.other;
  bool _isInstallment = false;
  String _installmentType = 'monthly';
  DateTime _firstInstallmentDate = DateTime.now();
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  List<dynamic> _accounts = [];

  void _loadAccounts() {
    _accounts = DatabaseService.accounts.values
        .where((a) => a.type == 'credit')
        .toList();
    if (_accounts.isNotEmpty) {
      _selectedAccountId = _accounts.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _installmentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double get _totalAmount => double.tryParse(_amountController.text) ?? 0;
  int get _installments => int.tryParse(_installmentController.text) ?? 1;
  double get _installmentAmount => _totalAmount / _installments;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isInstallment) {
        for (int i = 0; i < _installments; i++) {
          final transaction = TransactionModel(
            id: const Uuid().v4(),
            title: _titleController.text,
            amount: _installmentAmount,
            type: _type,
            category: _category,
            date: _getNextDate(i),
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            isInstallment: true,
            installmentTotal: _installments,
            installmentCurrent: i + 1,
            accountId: _selectedAccountId,
          );
          if (i == 0) {
            Navigator.pop(context, transaction);
          }
        }
      } else {
        final transaction = TransactionModel(
          id: const Uuid().v4(),
          title: _titleController.text,
          amount: _totalAmount,
          type: _type,
          category: _category,
          date: DateTime.now(),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          accountId: _selectedAccountId,
        );
        Navigator.pop(context, transaction);
      }
    }
  }

  DateTime _getNextDate(int index) {
    switch (_installmentType) {
      case 'weekly':
        return _firstInstallmentDate.add(Duration(days: index * 7));
      case 'biweekly':
        return _firstInstallmentDate.add(Duration(days: index * 15));
      case 'monthly':
      default:
        return DateTime(
          _firstInstallmentDate.year,
          _firstInstallmentDate.month + index,
          _firstInstallmentDate.day,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Nova Transação',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        TransactionTypeModel.income,
                        'Receita',
                        AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeButton(
                        TransactionTypeModel.expense,
                        'Despesa',
                        AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Preencha a descrição' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor Total',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Preencha o valor' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionCategoryModel>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: TransactionCategoryModel.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(_getCategoryName(c)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                if (_accounts.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Cartão (opcional)',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sem cartão'),
                      ),
                      ..._accounts.map(
                        (a) =>
                            DropdownMenuItem(value: a.id, child: Text(a.name)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedAccountId = v),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Parcelamento',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isInstallment,
                        onChanged: (v) => setState(() => _isInstallment = v),
                      ),
                    ],
                  ),
                ),
                if (_isInstallment) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '1ª Parcela',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _firstInstallmentDate,
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (picked != null) {
                                  setState(
                                    () => _firstInstallmentDate = picked,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_firstInstallmentDate.day}/${_firstInstallmentDate.month}/${_firstInstallmentDate.year}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tipo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _installmentType,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'weekly',
                                  child: Text('Semanal'),
                                ),
                                DropdownMenuItem(
                                  value: 'biweekly',
                                  child: Text('Quinzenal'),
                                ),
                                DropdownMenuItem(
                                  value: 'monthly',
                                  child: Text('Mensal'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _installmentType = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Parcelas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _installmentController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              validator: (v) {
                                if (!_isInstallment) return null;
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 2) return 'Mín 2';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resumo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_installments x de R\$ ${_installmentAmount.toStringAsFixed(2)} = R\$ ${_totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Última: ${_formatDate(_getNextDate(_installments - 1))}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      _isInstallment
                          ? 'Salvar $_installments Parcelas'
                          : 'Salvar Transação',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    TransactionTypeModel type,
    String label,
    Color color,
  ) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getCategoryName(TransactionCategoryModel category) {
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
}
