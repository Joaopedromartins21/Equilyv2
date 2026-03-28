import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionTypeModel {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
enum TransactionCategoryModel {
  @HiveField(0)
  salary,
  @HiveField(1)
  investment,
  @HiveField(2)
  food,
  @HiveField(3)
  transport,
  @HiveField(4)
  entertainment,
  @HiveField(5)
  health,
  @HiveField(6)
  education,
  @HiveField(7)
  shopping,
  @HiveField(8)
  bills,
  @HiveField(9)
  other,
}

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  TransactionTypeModel type;

  @HiveField(4)
  TransactionCategoryModel category;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? description;

  @HiveField(7)
  String? accountId;

  @HiveField(8)
  bool isInstallment;

  @HiveField(9)
  int? installmentTotal;

  @HiveField(10)
  int? installmentCurrent;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
    this.accountId,
    this.isInstallment = false,
    this.installmentTotal,
    this.installmentCurrent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.index,
      'category': category.index,
      'date': date.toIso8601String(),
      'description': description,
      'accountId': accountId,
      'isInstallment': isInstallment,
      'installmentTotal': installmentTotal,
      'installmentCurrent': installmentCurrent,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      type: TransactionTypeModel.values[map['type']],
      category: TransactionCategoryModel.values[map['category']],
      date: DateTime.parse(map['date']),
      description: map['description'],
      accountId: map['accountId'],
      isInstallment: map['isInstallment'] ?? false,
      installmentTotal: map['installmentTotal'],
      installmentCurrent: map['installmentCurrent'],
    );
  }
}
