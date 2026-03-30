import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/account_model.dart';

class AdvancedFilters extends StatefulWidget {
  final List<TransactionModel> transactions;
  final List<AccountModel> accounts;
  final Function(List<TransactionModel>) onFilterChanged;

  const AdvancedFilters({
    super.key,
    required this.transactions,
    required this.accounts,
    required this.onFilterChanged,
  });

  @override
  State<AdvancedFilters> createState() => _AdvancedFiltersState();
}

class _AdvancedFiltersState extends State<AdvancedFilters> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedAccountId;
  TransactionCategoryModel? _selectedCategory;
  TransactionTypeModel? _selectedType;
  String _searchQuery = '';

  final List<String> _periodOptions = [
    'Este mês',
    'Mês passado',
    'Últimos 3 meses',
    'Últimos 6 meses',
    'Este ano',
    'Personalizado',
  ];
  String _selectedPeriod = 'Este mês';

  @override
  void initState() {
    super.initState();
    _applyPeriodFilter(_selectedPeriod);
  }

  void _applyPeriodFilter(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Este mês':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Mês passado':
        _startDate = DateTime(now.year, now.month - 1, 1);
        _endDate = DateTime(now.year, now.month, 0);
        break;
      case 'Últimos 3 meses':
        _startDate = DateTime(now.year, now.month - 3, 1);
        _endDate = now;
        break;
      case 'Últimos 6 meses':
        _startDate = DateTime(now.year, now.month - 6, 1);
        _endDate = now;
        break;
      case 'Este ano':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
      case 'Personalizado':
        break;
    }
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = widget.transactions.where((t) {
      if (_startDate != null && t.date.isBefore(_startDate!)) return false;
      if (_endDate != null && t.date.isAfter(_endDate!)) return false;
      if (_selectedAccountId != null && t.accountId != _selectedAccountId)
        return false;
      if (_selectedCategory != null && t.category != _selectedCategory)
        return false;
      if (_selectedType != null && t.type != _selectedType) return false;
      if (_searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        return false;
      return true;
    }).toList();

    widget.onFilterChanged(filtered);
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedAccountId = null;
      _selectedCategory = null;
      _selectedType = null;
      _searchQuery = '';
      _selectedPeriod = 'Este mês';
      _applyPeriodFilter(_selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filtros Avançados',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Limpar'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  decoration: InputDecoration(
                    labelText: 'Período',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  items: _periodOptions
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p, style: const TextStyle(fontSize: 13)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPeriod = value);
                      _applyPeriodFilter(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              if (_selectedPeriod == 'Personalizado') ...[
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                      _applyFilters();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _startDate != null
                          ? dateFormat.format(_startDate!)
                          : 'Data inicial',
                      style: TextStyle(
                        fontSize: 13,
                        color: _startDate != null
                            ? AppTheme.textPrimary
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                      _applyFilters();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _endDate != null
                          ? dateFormat.format(_endDate!)
                          : 'Data final',
                      style: TextStyle(
                        fontSize: 13,
                        color: _endDate != null
                            ? AppTheme.textPrimary
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: InputDecoration(
                    labelText: 'Conta',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todas', style: TextStyle(fontSize: 13)),
                    ),
                    ...widget.accounts.map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(
                          a.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedAccountId = value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TransactionCategoryModel>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todas', style: TextStyle(fontSize: 13)),
                    ),
                    ...TransactionCategoryModel.values.map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          _getCategoryName(c),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TransactionTypeModel>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Todos', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: TransactionTypeModel.income,
                      child: Text('Receita', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: TransactionTypeModel.expense,
                      child: Text('Despesa', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedType = value);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
