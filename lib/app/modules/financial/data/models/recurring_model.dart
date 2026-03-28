import 'package:hive/hive.dart';

part 'recurring_model.g.dart';

@HiveType(typeId: 6)
enum RecurrenceType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}

@HiveType(typeId: 7)
class RecurringTransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category;

  @HiveField(4)
  String type; // income ou expense

  @HiveField(5)
  RecurrenceType recurrence;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime? endDate;

  @HiveField(8)
  DateTime? lastProcessed;

  @HiveField(9)
  bool isActive;

  @HiveField(10)
  String? accountId;

  RecurringTransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.recurrence,
    required this.startDate,
    this.endDate,
    this.lastProcessed,
    this.isActive = true,
    this.accountId,
  });

  DateTime getNextDate() {
    final last = lastProcessed ?? startDate;
    switch (recurrence) {
      case RecurrenceType.daily:
        return last.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return last.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        return DateTime(last.year, last.month + 1, last.day);
      case RecurrenceType.yearly:
        return DateTime(last.year + 1, last.month, last.day);
    }
  }

  bool shouldProcess() {
    if (!isActive) return false;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return false;
    return DateTime.now().isAfter(getNextDate());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'recurrence': recurrence.index,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'lastProcessed': lastProcessed?.toIso8601String(),
      'isActive': isActive,
      'accountId': accountId,
    };
  }

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      type: map['type'],
      recurrence: RecurrenceType.values[map['recurrence']],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      lastProcessed: map['lastProcessed'] != null
          ? DateTime.parse(map['lastProcessed'])
          : null,
      isActive: map['isActive'] ?? true,
      accountId: map['accountId'],
    );
  }
}
