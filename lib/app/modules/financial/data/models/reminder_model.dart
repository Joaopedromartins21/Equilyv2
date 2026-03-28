import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 8)
enum ReminderType {
  @HiveField(0)
  bill,
  @HiveField(1)
  due,
  @HiveField(2)
  custom,
}

@HiveType(typeId: 9)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  ReminderType type;

  @HiveField(5)
  bool isPaid;

  @HiveField(6)
  String? category;

  @HiveField(7)
  bool repeatMonthly;

  @HiveField(8)
  DateTime createdAt;

  ReminderModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.type,
    this.isPaid = false,
    this.category,
    this.repeatMonthly = false,
    required this.createdAt,
  });

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());
  bool get isDueToday =>
      !isPaid &&
      dueDate.day == DateTime.now().day &&
      dueDate.month == DateTime.now().month &&
      dueDate.year == DateTime.now().year;
  bool get isDueSoon =>
      !isPaid && !isOverdue && dueDate.difference(DateTime.now()).inDays <= 3;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'type': type.index,
      'isPaid': isPaid,
      'category': category,
      'repeatMonthly': repeatMonthly,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate']),
      type: ReminderType.values[map['type']],
      isPaid: map['isPaid'] ?? false,
      category: map['category'],
      repeatMonthly: map['repeatMonthly'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
