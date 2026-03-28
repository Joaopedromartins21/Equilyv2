import 'package:hive/hive.dart';

part 'debt_model.g.dart';

@HiveType(typeId: 10)
enum DebtType {
  @HiveField(0)
  owedToMe, // alguém me deve
  @HiveField(1)
  iOwe, // eu devo
}

@HiveType(typeId: 11)
class DebtModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String personName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String? description;

  @HiveField(4)
  DebtType type;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? dueDate;

  @HiveField(7)
  bool isPaid;

  @HiveField(8)
  String? phone;

  DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    this.description,
    required this.type,
    required this.createdAt,
    this.dueDate,
    this.isPaid = false,
    this.phone,
  });

  bool get isOverdue =>
      !isPaid && dueDate != null && dueDate!.isBefore(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'amount': amount,
      'description': description,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isPaid': isPaid,
      'phone': phone,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'],
      personName: map['personName'],
      amount: (map['amount'] as num).toDouble(),
      description: map['description'],
      type: DebtType.values[map['type']],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isPaid: map['isPaid'] ?? false,
      phone: map['phone'],
    );
  }
}
