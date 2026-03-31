import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../../modules/financial/data/models/transaction_model.dart';
import '../../modules/financial/data/models/account_model.dart';
import '../../modules/financial/data/models/goal_model.dart';
import '../../modules/financial/data/models/budget_model.dart';
import '../../modules/financial/data/models/recurring_model.dart';
import '../../modules/financial/data/models/reminder_model.dart';
import '../../modules/financial/data/models/debt_model.dart';
import '../../modules/habits/data/models/habit_model.dart';

class _CacheBox<T> {
  final Map<String, T> _items = {};
  final String Function(T) getId;

  _CacheBox({required this.getId});

  List<T> get values => _items.values.toList();

  void add(T item) {
    _items[getId(item)] = item;
  }

  void removeWhere(bool Function(T) test) {
    _items.removeWhere((_, item) => test(item));
  }

  T? getById(String id) => _items[id];

  void clear() => _items.clear();

  void addAll(Iterable<T> items) {
    for (final item in items) {
      _items[getId(item)] = item;
    }
  }

  Future<void> put(String id, T item) async {
    _items[id] = item;
  }

  Future<void> delete(String id) async {
    _items.remove(id);
  }
}

class DatabaseService {
  static const String transactionsBox = 'transactions';
  static const String accountsBox = 'accounts';
  static const String goalsBox = 'goals';
  static const String budgetsBox = 'budgets';
  static const String recurringBox = 'recurring';
  static const String remindersBox = 'reminders';
  static const String debtsBox = 'debts';
  static const String habitsBox = 'habits';
  static const String settingsBox = 'settings';

  static final _CacheBox<TransactionModel> _transactionsCache =
      _CacheBox<TransactionModel>(getId: (t) => t.id);

  static final _CacheBox<AccountModel> _accountsCache = _CacheBox<AccountModel>(
    getId: (a) => a.id,
  );

  static final _CacheBox<GoalModel> _goalsCache = _CacheBox<GoalModel>(
    getId: (g) => g.id,
  );

  static final _CacheBox<BudgetModel> _budgetsCache = _CacheBox<BudgetModel>(
    getId: (b) => b.id,
  );

  static final _CacheBox<RecurringTransactionModel> _recurringCache =
      _CacheBox<RecurringTransactionModel>(getId: (r) => r.id);

  static final _CacheBox<ReminderModel> _remindersCache =
      _CacheBox<ReminderModel>(getId: (r) => r.id);

  static final _CacheBox<DebtModel> _debtsCache = _CacheBox<DebtModel>(
    getId: (d) => d.id,
  );

  static final _CacheBox<HabitModel> _habitsCache = _CacheBox<HabitModel>(
    getId: (h) => h.id,
  );

  static _CacheBox<TransactionModel> get transactions => _transactionsCache;
  static _CacheBox<AccountModel> get accounts => _accountsCache;
  static _CacheBox<GoalModel> get goals => _goalsCache;
  static _CacheBox<BudgetModel> get budgets => _budgetsCache;
  static _CacheBox<RecurringTransactionModel> get recurring => _recurringCache;
  static _CacheBox<ReminderModel> get reminders => _remindersCache;
  static _CacheBox<DebtModel> get debts => _debtsCache;
  static _CacheBox<HabitModel> get habits => _habitsCache;

  static Future<void> init() async {
    await loadAllData();
  }

  static Future<void> loadAllData() async {
    _transactionsCache.clear();
    final txs = await getAllTransactions();
    for (var t in txs) {
      _transactionsCache.add(t);
    }

    _accountsCache.clear();
    final acts = await getAllAccounts();
    for (var a in acts) {
      _accountsCache.add(a);
    }

    _goalsCache.clear();
    final goalsList = await getAllGoals();
    for (var g in goalsList) {
      _goalsCache.add(g);
    }

    _budgetsCache.clear();
    final buds = await getAllBudgets();
    for (var b in buds) {
      _budgetsCache.add(b);
    }

    _recurringCache.clear();
    final recur = await getAllRecurring();
    for (var r in recur) {
      _recurringCache.add(r);
    }

    _remindersCache.clear();
    final rems = await getAllReminders();
    for (var r in rems) {
      _remindersCache.add(r);
    }

    _debtsCache.clear();
    final debts = await getAllDebts();
    for (var d in debts) {
      _debtsCache.add(d);
    }

    _habitsCache.clear();
    final habitsList = await getAllHabits();
    for (var h in habitsList) {
      _habitsCache.add(h);
    }
  }

  // Transactions
  static Future<List<TransactionModel>> getAllTransactions() async {
    final docs = await FirebaseService.getAllDocuments(transactionsBox);
    return docs
        .map(
          (doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  static Stream<QuerySnapshot> transactionsStream() {
    return FirebaseService.transactions.snapshots();
  }

  static Future<void> addTransaction(TransactionModel transaction) async {
    await FirebaseService.addDocument(
      transactionsBox,
      transaction.id,
      transaction.toMap(),
    );
    _transactionsCache.add(transaction);
  }

  static Future<void> updateTransaction(TransactionModel transaction) async {
    await FirebaseService.updateDocument(
      transactionsBox,
      transaction.id,
      transaction.toMap(),
    );
    _transactionsCache.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    await FirebaseService.deleteDocument(transactionsBox, id);
    _transactionsCache.delete(id);
  }

  // Accounts
  static Future<List<AccountModel>> getAllAccounts() async {
    final docs = await FirebaseService.getAllDocuments(accountsBox);
    return docs
        .map((doc) => AccountModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Stream<QuerySnapshot> accountsStream() {
    return FirebaseService.accounts.snapshots();
  }

  static Future<void> addAccount(AccountModel account) async {
    await FirebaseService.addDocument(accountsBox, account.id, account.toMap());
    _accountsCache.add(account);
  }

  static Future<void> updateAccount(AccountModel account) async {
    await FirebaseService.updateDocument(
      accountsBox,
      account.id,
      account.toMap(),
    );
    _accountsCache.put(account.id, account);
  }

  static Future<void> deleteAccount(String id) async {
    await FirebaseService.deleteDocument(accountsBox, id);
    _accountsCache.delete(id);
  }

  // Goals
  static Future<List<GoalModel>> getAllGoals() async {
    final docs = await FirebaseService.getAllDocuments(goalsBox);
    return docs
        .map((doc) => GoalModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Stream<QuerySnapshot> goalsStream() {
    return FirebaseService.goals.snapshots();
  }

  static Future<void> addGoal(GoalModel goal) async {
    await FirebaseService.addDocument(goalsBox, goal.id, goal.toMap());
    _goalsCache.add(goal);
  }

  static Future<void> updateGoal(GoalModel goal) async {
    await FirebaseService.updateDocument(goalsBox, goal.id, goal.toMap());
    _goalsCache.put(goal.id, goal);
  }

  static Future<void> deleteGoal(String id) async {
    await FirebaseService.deleteDocument(goalsBox, id);
    _goalsCache.delete(id);
  }

  // Budgets
  static Future<List<BudgetModel>> getAllBudgets() async {
    final docs = await FirebaseService.getAllDocuments(budgetsBox);
    return docs
        .map((doc) => BudgetModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Stream<QuerySnapshot> budgetsStream() {
    return FirebaseService.budgets.snapshots();
  }

  static Future<void> addBudget(BudgetModel budget) async {
    await FirebaseService.addDocument(budgetsBox, budget.id, budget.toMap());
    _budgetsCache.add(budget);
  }

  static Future<void> updateBudget(BudgetModel budget) async {
    await FirebaseService.updateDocument(budgetsBox, budget.id, budget.toMap());
    _budgetsCache.put(budget.id, budget);
  }

  static Future<void> deleteBudget(String id) async {
    await FirebaseService.deleteDocument(budgetsBox, id);
    _budgetsCache.delete(id);
  }

  // Recurring
  static Future<List<RecurringTransactionModel>> getAllRecurring() async {
    final docs = await FirebaseService.getAllDocuments(recurringBox);
    return docs
        .map(
          (doc) => RecurringTransactionModel.fromMap(
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static Stream<QuerySnapshot> recurringStream() {
    return FirebaseService.recurring.snapshots();
  }

  static Future<void> addRecurring(RecurringTransactionModel recurring) async {
    await FirebaseService.addDocument(
      recurringBox,
      recurring.id,
      recurring.toMap(),
    );
    _recurringCache.add(recurring);
  }

  static Future<void> updateRecurring(
    RecurringTransactionModel recurring,
  ) async {
    await FirebaseService.updateDocument(
      recurringBox,
      recurring.id,
      recurring.toMap(),
    );
    _recurringCache.put(recurring.id, recurring);
  }

  static Future<void> deleteRecurring(String id) async {
    await FirebaseService.deleteDocument(recurringBox, id);
    _recurringCache.delete(id);
  }

  // Reminders
  static Future<List<ReminderModel>> getAllReminders() async {
    final docs = await FirebaseService.getAllDocuments(remindersBox);
    return docs
        .map((doc) => ReminderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Stream<QuerySnapshot> remindersStream() {
    return FirebaseService.reminders.snapshots();
  }

  static Future<void> addReminder(ReminderModel reminder) async {
    await FirebaseService.addDocument(
      remindersBox,
      reminder.id,
      reminder.toMap(),
    );
    _remindersCache.add(reminder);
  }

  static Future<void> updateReminder(ReminderModel reminder) async {
    await FirebaseService.updateDocument(
      remindersBox,
      reminder.id,
      reminder.toMap(),
    );
    _remindersCache.put(reminder.id, reminder);
  }

  static Future<void> deleteReminder(String id) async {
    await FirebaseService.deleteDocument(remindersBox, id);
    _remindersCache.delete(id);
  }

  // Debts
  static Future<List<DebtModel>> getAllDebts() async {
    final docs = await FirebaseService.getAllDocuments(debtsBox);
    return docs
        .map((doc) => DebtModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Stream<QuerySnapshot> debtsStream() {
    return FirebaseService.debts.snapshots();
  }

  static Future<void> addDebt(DebtModel debt) async {
    await FirebaseService.addDocument(debtsBox, debt.id, debt.toMap());
    _debtsCache.add(debt);
  }

  static Future<void> updateDebt(DebtModel debt) async {
    await FirebaseService.updateDocument(debtsBox, debt.id, debt.toMap());
    _debtsCache.put(debt.id, debt);
  }

  static Future<void> deleteDebt(String id) async {
    await FirebaseService.deleteDocument(debtsBox, id);
    _debtsCache.delete(id);
  }

  // Habits
  static Future<List<HabitModel>> getAllHabits() async {
    final docs = await FirebaseService.getAllDocuments(habitsBox);
    return docs
        .map((doc) => HabitModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addHabit(HabitModel habit) async {
    await FirebaseService.addDocument(habitsBox, habit.id, habit.toMap());
    _habitsCache.add(habit);
  }

  static Future<void> updateHabit(HabitModel habit) async {
    await FirebaseService.updateDocument(habitsBox, habit.id, habit.toMap());
    _habitsCache.put(habit.id, habit);
  }

  static Future<void> deleteHabit(String id) async {
    await FirebaseService.deleteDocument(habitsBox, id);
    _habitsCache.delete(id);
  }

  static Future<String> exportAllData() async {
    final transactions = await getAllTransactions();
    final accounts = await getAllAccounts();
    final goals = await getAllGoals();
    final budgets = await getAllBudgets();
    final recurring = await getAllRecurring();

    final data = {
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'accounts': accounts.map((a) => a.toMap()).toList(),
      'goals': goals.map((g) => g.toMap()).toList(),
      'budgets': budgets.map((b) => b.toMap()).toList(),
      'recurring': recurring.map((r) => r.toMap()).toList(),
    };
    return jsonEncode(data);
  }

  static Future<void> importAllData(String jsonData) async {
    final data = jsonDecode(jsonData) as Map<String, dynamic>;

    for (var t in (data['transactions'] as List)) {
      await addTransaction(TransactionModel.fromMap(t));
    }

    for (var a in (data['accounts'] as List)) {
      await addAccount(AccountModel.fromMap(a));
    }

    for (var g in (data['goals'] as List)) {
      await addGoal(GoalModel.fromMap(g));
    }

    for (var b in (data['budgets'] as List)) {
      await addBudget(BudgetModel.fromMap(b));
    }

    for (var r in (data['recurring'] as List)) {
      await addRecurring(RecurringTransactionModel.fromMap(r));
    }
  }

  static Future<void> seedInitialData() async {
    final existingTransactions = await getAllTransactions();
    if (existingTransactions.isEmpty) {
      final now = DateTime.now();
      final seeds = [
        TransactionModel(
          id: '1',
          title: 'Salário',
          amount: 5000.00,
          type: TransactionTypeModel.income,
          category: TransactionCategoryModel.salary,
          date: now.subtract(const Duration(days: 2)),
          accountId: 'default',
        ),
        TransactionModel(
          id: '2',
          title: 'Supermercado',
          amount: 350.00,
          type: TransactionTypeModel.expense,
          category: TransactionCategoryModel.food,
          date: now.subtract(const Duration(days: 1)),
          accountId: 'default',
        ),
        TransactionModel(
          id: '3',
          title: 'Uber',
          amount: 45.00,
          type: TransactionTypeModel.expense,
          category: TransactionCategoryModel.transport,
          date: now,
          accountId: 'default',
        ),
        TransactionModel(
          id: '4',
          title: 'Netflix',
          amount: 55.90,
          type: TransactionTypeModel.expense,
          category: TransactionCategoryModel.entertainment,
          date: now,
          accountId: 'default',
        ),
        TransactionModel(
          id: '5',
          title: 'Freelance',
          amount: 1200.00,
          type: TransactionTypeModel.income,
          category: TransactionCategoryModel.investment,
          date: now.subtract(const Duration(days: 5)),
          accountId: 'default',
        ),
      ];
      for (var t in seeds) {
        await addTransaction(t);
      }
    }

    final existingAccounts = await getAllAccounts();
    if (existingAccounts.isEmpty) {
      final defaultAccount = AccountModel(
        id: 'default',
        name: 'Conta Principal',
        balance: 5000.00,
        color: 0xFF6C63FF,
        type: 'checking',
      );
      await addAccount(defaultAccount);
    }
  }
}
