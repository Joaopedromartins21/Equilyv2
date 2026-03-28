import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final List<Transaction> _transactions = [];

  TransactionRepositoryImpl() {
    _initMockData();
  }

  void _initMockData() {
    _transactions.addAll([
      Transaction(
        id: '1',
        title: 'Salário',
        amount: 5000.00,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: '2',
        title: 'Supermercado',
        amount: 350.00,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '3',
        title: 'Uber',
        amount: 45.00,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: DateTime.now(),
      ),
      Transaction(
        id: '4',
        title: 'Netflix',
        amount: 55.90,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        date: DateTime.now(),
      ),
      Transaction(
        id: '5',
        title: 'Freelance',
        amount: 1200.00,
        type: TransactionType.income,
        category: TransactionCategory.investment,
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _transactions..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return _transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
  }
}
