import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../../widgets/empty_state.dart';
import '../../../../../widgets/skeleton_loading.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/services/backup_service.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/account_model.dart';
import '../../data/models/goal_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/transaction_details.dart';
import '../widgets/financial_charts.dart';
import '../widgets/stats_card.dart';
import '../widgets/accounts_panel.dart';
import '../widgets/goals_panel.dart';
import '../widgets/budget_panel.dart';
import '../widgets/transfer_dialog.dart';
import '../widgets/monthly_chart.dart';
import '../widgets/monthly_comparison.dart';
import '../widgets/spending_projection.dart';
import '../widgets/category_alerts.dart';
import '../widgets/advanced_filters.dart';
import '../widgets/recurring_panel.dart';
import '../widgets/installments_panel.dart';
import '../widgets/reminders_debts_panel.dart';
import '../widgets/calendar_panel.dart';
import '../widgets/daily_panel.dart';

class FinancialPage extends StatefulWidget {
  const FinancialPage({super.key});

  @override
  State<FinancialPage> createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];
  List<GoalModel> _goals = [];
  TransactionModel? _selectedTransaction;
  String _searchQuery = '';
  TransactionTypeModel? _filterType;
  bool _isLoading = true;
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _transactions = DatabaseService.transactions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _accounts = DatabaseService.accounts.values.toList();
    _goals = DatabaseService.goals.values.toList();

    setState(() => _isLoading = false);
  }

  double get _totalIncome {
    return _transactions
        .where((t) => t.type == TransactionTypeModel.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _totalExpense {
    return _transactions
        .where((t) => t.type == TransactionTypeModel.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _balance => _totalIncome - _totalExpense;

  List<TransactionModel> get _filteredTransactions {
    return _transactions.where((t) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == null || t.type == _filterType;
      return matchesSearch && matchesType;
    }).toList();
  }

  double get _avgDailyExpense {
    if (_transactions.isEmpty) return 0;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return _totalExpense / daysInMonth;
  }

  void _showTransferDialog() async {
    if (_accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre pelo menos 2 contas para fazer transferências',
          ),
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TransferDialog(accounts: _accounts),
    );

    if (result != null) {
      final expense = result['expense'] as TransactionModel;
      final income = result['income'] as TransactionModel;
      final from = result['from'];
      final to = result['to'];
      final amount = result['amount'] as double;

      await DatabaseService.transactions.put(expense.id, expense);
      await DatabaseService.transactions.put(income.id, income);

      from.balance -= amount;
      to.balance += amount;
      await DatabaseService.accounts.put(from.id, from);
      await DatabaseService.accounts.put(to.id, to);

      _loadData();
    }
  }

  void _addTransaction() async {
    final result = await showDialog<TransactionModel>(
      context: context,
      builder: (context) => const AddTransactionSheet(),
    );
    if (result != null) {
      await DatabaseService.transactions.put(result.id, result);
      await _updateAccountBalance(result);
      _loadData();
    }
  }

  Future<void> _updateAccountBalance(TransactionModel transaction) async {
    if (_accounts.isEmpty) return;

    final accountId = transaction.accountId ?? 'default';
    final account = _accounts.firstWhere(
      (a) => a.id == accountId,
      orElse: () => _accounts.first,
    );

    if (transaction.type == TransactionTypeModel.income) {
      account.balance += transaction.amount;
    } else {
      account.balance -= transaction.amount;
    }

    await DatabaseService.accounts.put(account.id, account);
  }

  Future<void> _exportReport() async {
    final option = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Relatório'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              subtitle: const Text('Relatório formatado'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel (.xls)'),
              subtitle: const Text('Planilha do Excel'),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('CSV'),
              subtitle: const Text('Arquivo de texto separado por vírgulas'),
              onTap: () => Navigator.pop(context, 'csv'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (option == null) return;

    try {
      String path;
      if (option == 'pdf') {
        path = await ExportService.exportToPdf(
          _transactions,
          _totalIncome,
          _totalExpense,
          _balance,
        );
      } else if (option == 'excel') {
        path = await ExportService.exportToExcel(
          _transactions,
          _totalIncome,
          _totalExpense,
          _balance,
        );
      } else {
        path = await ExportService.exportToCsv(
          _transactions,
          _totalIncome,
          _totalExpense,
          _balance,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Relatório salvo em: $path'),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionsTab(),
                  _buildAccountsTab(),
                  _buildInstallmentsTab(),
                  _buildRecurringTab(),
                  _buildRemindersDebtsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financeiro',
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
          ],
        ),
        const Spacer(),
        SizedBox(
          width: 250,
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Buscar transações...',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _showTransferDialog,
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: const Text('Transferir'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _exportReport,
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          label: const Text('Exportar'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _addTransaction,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nova Transação'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: StatsCard(
              title: 'Média Diária',
              value: 'R\$ ${_avgDailyExpense.toStringAsFixed(2)}',
              icon: Icons.calendar_today,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatsCard(
              title: 'Total Transações',
              value: _transactions.length.toString(),
              icon: Icons.receipt_long,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatsCard(
              title: 'Contas',
              value: _accounts.length.toString(),
              icon: Icons.account_balance,
              color: Colors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatsCard(
              title: 'Metas',
              value: _goals.length.toString(),
              icon: Icons.flag,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2,
        labelStyle: const TextStyle(fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: const [
          Tab(text: 'Transações', icon: Icon(Icons.receipt_long, size: 18)),
          Tab(text: 'Contas', icon: Icon(Icons.account_balance, size: 18)),
          Tab(text: 'Parcelas', icon: Icon(Icons.credit_card, size: 18)),
          Tab(text: 'Gastos Fixos', icon: Icon(Icons.repeat, size: 18)),
          Tab(
            text: 'Contas/Dívidas',
            icon: Icon(Icons.warning_amber, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildMainContent()),
        const SizedBox(width: 24),
        SizedBox(width: 350, child: _buildSidePanel()),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Row(
            children: [
              SizedBox(
                width: 400,
                child: BalanceCard(
                  balance: _balance,
                  income: _totalIncome,
                  expense: _totalExpense,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickStats()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MonthlyComparison(transactions: _transactions),
        const SizedBox(height: 16),
        SpendingProjection(transactions: _transactions),
        const SizedBox(height: 16),
        CategoryAlerts(transactions: _transactions),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildFilters(),
            const Spacer(),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _showAdvancedFilters = !_showAdvancedFilters),
              icon: Icon(
                _showAdvancedFilters
                    ? Icons.filter_list_off
                    : Icons.filter_list,
                size: 18,
              ),
              label: Text(
                _showAdvancedFilters ? 'Ocultar Filtros' : 'Filtros Avançados',
              ),
            ),
          ],
        ),
        if (_showAdvancedFilters) ...[
          const SizedBox(height: 12),
          AdvancedFilters(
            transactions: _transactions,
            accounts: _accounts,
            onFilterChanged: (filtered) {
              setState(() {
                _transactions = filtered;
              });
            },
          ),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Transações',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_filteredTransactions.length} registros',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _filteredTransactions[index];
                            return TransactionTile(
                              transaction: transaction,
                              isSelected:
                                  _selectedTransaction?.id == transaction.id,
                              onTap: () => setState(
                                () => _selectedTransaction = transaction,
                              ),
                              onDelete: () async {
                                await DatabaseService.transactions.delete(
                                  transaction.id,
                                );
                                _loadData();
                              },
                              onEdit: () async {
                                final result =
                                    await showDialog<TransactionModel>(
                                      context: context,
                                      builder: (context) =>
                                          const AddTransactionSheet(),
                                    );
                                if (result != null) {
                                  await DatabaseService.transactions.put(
                                    result.id,
                                    result,
                                  );
                                  _loadData();
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _buildFilterChip(null, 'Todas'),
        const SizedBox(width: 8),
        _buildFilterChip(TransactionTypeModel.income, 'Receitas'),
        const SizedBox(width: 8),
        _buildFilterChip(TransactionTypeModel.expense, 'Despesas'),
      ],
    );
  }

  Widget _buildFilterChip(TransactionTypeModel? type, String label) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterType = type),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Nenhuma transação encontrada',
      subtitle: _searchQuery.isNotEmpty || _filterType != null
          ? 'Tente ajustar seus filtros de busca'
          : 'Comece a registrar suas transações financeiras',
    );
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoading(height: 32, width: 200),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: const SkeletonLoading(height: 100)),
                const SizedBox(width: 16),
                Expanded(child: const SkeletonLoading(height: 100)),
                const SizedBox(width: 16),
                Expanded(child: const SkeletonLoading(height: 100)),
              ],
            ),
            const SizedBox(height: 24),
            const SkeletonLoading(height: 40),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const SkeletonLoading(
                          height: 48,
                          width: 48,
                          borderRadius: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SkeletonLoading(height: 16, width: 120),
                              SizedBox(height: 8),
                              SkeletonLoading(height: 12, width: 80),
                            ],
                          ),
                        ),
                        const SkeletonLoading(height: 20, width: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalhes da Transação',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (_selectedTransaction != null)
                TransactionDetails(transaction: _selectedTransaction!)
              else
                Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 36,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecione uma transação',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Por Categoria',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Expanded(child: FinancialCharts(transactions: _transactions)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsTab() {
    return AccountsPanel(accounts: _accounts, onRefresh: _loadData);
  }

  Widget _buildGoalsTab() {
    return GoalsPanel(goals: _goals, onRefresh: _loadData);
  }

  Widget _buildBudgetsTab() {
    return BudgetPanel(transactions: _transactions, onRefresh: _loadData);
  }

  Widget _buildInstallmentsTab() {
    return InstallmentsPanel(onRefresh: _loadData);
  }

  Widget _buildRecurringTab() {
    return RecurringPanel(onRefresh: _loadData);
  }

  Widget _buildDailyTab() {
    return DailyPanel(onRefresh: _loadData);
  }

  Widget _buildCalendarTab() {
    return CalendarPanel(onRefresh: _loadData);
  }

  Widget _buildRemindersDebtsTab() {
    return RemindersDebtsPanel(onRefresh: _loadData);
  }

  Widget _buildDashboardTab() {
    return _buildDashboard();
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildDashboardCard(
                'Receitas',
                'R\$ ${_totalIncome.toStringAsFixed(2)}',
                Icons.arrow_upward,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildDashboardCard(
                'Despesas',
                'R\$ ${_totalExpense.toStringAsFixed(2)}',
                Icons.arrow_downward,
                Colors.red,
              ),
              const SizedBox(width: 16),
              _buildDashboardCard(
                'Saldo',
                'R\$ ${_balance.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                AppTheme.primaryColor,
              ),
              const SizedBox(width: 16),
              _buildDashboardCard(
                'Transações',
                _transactions.length.toString(),
                Icons.receipt_long,
                Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tendência de 6 meses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Expanded(child: MonthlyChart(transactions: [])),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Container(
                  height: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Por Categoria',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: FinancialCharts(transactions: _transactions),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Receitas',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  'R\$ ${_totalIncome.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Despesas',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  'R\$ ${_totalExpense.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              child: Icon(icon, color: color, size: 16),
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
      ),
    );
  }
}
