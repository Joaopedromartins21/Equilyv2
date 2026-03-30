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
  final List<T> _items = [];
  T Function(Map<String, dynamic>) fromMap;
  Map<String, dynamic> Function(T) toMap;
  String Function(T) getId;

  _CacheBox({required this.fromMap, required this.toMap, required this.getId});

  List<T> get values => _items;

  void add(T item) => _items.add(item);

  void removeWhere(bool Function(T) test) => _items.removeWhere(test);

  int indexWhere(bool Function(T) test) => _items.indexWhere(test);

  void operator []=(int index, T item) => _items[index] = item;

  void clear() => _items.clear();

  void addAll(Iterable<T> items) => _items.addAll(items);

  Future<void> put(String id, T item) async {
    final index = _items.indexWhere((i) => getId(i) == id);
    if (index != -1) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
  }

  Future<void> delete(String id) async {
    _items.removeWhere((i) => getId(i) == id);
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
      _CacheBox<TransactionModel>(
        fromMap: TransactionModel.fromMap,
        toMap: (t) => t.toMap(),
        getId: (t) => t.id,
      );

  static final _CacheBox<AccountModel> _accountsCache = _CacheBox<AccountModel>(
    fromMap: AccountModel.fromMap,
    toMap: (a) => a.toMap(),
    getId: (a) => a.id,
  );

  static final _CacheBox<GoalModel> _goalsCache = _CacheBox<GoalModel>(
    fromMap: GoalModel.fromMap,
    toMap: (g) => g.toMap(),
    getId: (g) => g.id,
  );

  static final _CacheBox<BudgetModel> _budgetsCache = _CacheBox<BudgetModel>(
    fromMap: BudgetModel.fromMap,
    toMap: (b) => b.toMap(),
    getId: (b) => b.id,
  );

  static final _CacheBox<RecurringTransactionModel> _recurringCache =
      _CacheBox<RecurringTransactionModel>(
        fromMap: RecurringTransactionModel.fromMap,
        toMap: (r) => r.toMap(),
        getId: (r) => r.id,
      );

  static final _CacheBox<ReminderModel> _remindersCache =
      _CacheBox<ReminderModel>(
        fromMap: ReminderModel.fromMap,
        toMap: (r) => r.toMap(),
        getId: (r) => r.id,
      );

  static final _CacheBox<DebtModel> _debtsCache = _CacheBox<DebtModel>(
    fromMap: DebtModel.fromMap,
    toMap: (d) => d.toMap(),
    getId: (d) => d.id,
  );

  static final _CacheBox<HabitModel> _habitsCache = _CacheBox<HabitModel>(
    fromMap: HabitModel.fromMap,
    toMap: (h) => h.toMap(),
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
    final index = _transactionsCache.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactionsCache[index] = transaction;
    }
  }

  static Future<void> deleteTransaction(String id) async {
    await FirebaseService.deleteDocument(transactionsBox, id);
    _transactionsCache.removeWhere((t) => t.id == id);
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
    final index = _accountsCache.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accountsCache[index] = account;
    }
  }

  static Future<void> deleteAccount(String id) async {
    await FirebaseService.deleteDocument(accountsBox, id);
    _accountsCache.removeWhere((a) => a.id == id);
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
    final index = _goalsCache.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goalsCache[index] = goal;
    }
  }

  static Future<void> deleteGoal(String id) async {
    await FirebaseService.deleteDocument(goalsBox, id);
    _goalsCache.removeWhere((g) => g.id == id);
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
    final index = _budgetsCache.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgetsCache[index] = budget;
    }
  }

  static Future<void> deleteBudget(String id) async {
    await FirebaseService.deleteDocument(budgetsBox, id);
    _budgetsCache.removeWhere((b) => b.id == id);
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
    final index = _recurringCache.indexWhere((r) => r.id == recurring.id);
    if (index != -1) {
      _recurringCache[index] = recurring;
    }
  }

  static Future<void> deleteRecurring(String id) async {
    await FirebaseService.deleteDocument(recurringBox, id);
    _recurringCache.removeWhere((r) => r.id == id);
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
    final index = _remindersCache.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _remindersCache[index] = reminder;
    }
  }

  static Future<void> deleteReminder(String id) async {
    await FirebaseService.deleteDocument(remindersBox, id);
    _remindersCache.removeWhere((r) => r.id == id);
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
    final index = _debtsCache.indexWhere((d) => d.id == debt.id);
    if (index != -1) {
      _debtsCache[index] = debt;
    }
  }

  static Future<void> deleteDebt(String id) async {
    await FirebaseService.deleteDocument(debtsBox, id);
    _debtsCache.removeWhere((d) => d.id == id);
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
    final index = _habitsCache.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habitsCache[index] = habit;
    }
  }

  static Future<void> deleteHabit(String id) async {
    await FirebaseService.deleteDocument(habitsBox, id);
    _habitsCache.removeWhere((h) => h.id == id);
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
