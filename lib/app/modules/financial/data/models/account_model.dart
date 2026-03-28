import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 3)
class AccountModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double balance;

  @HiveField(3)
  String currency;

  @HiveField(4)
  int color;

  @HiveField(5)
  String type;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  double? creditLimit;

  @HiveField(8)
  int? dueDay;

  @HiveField(9)
  int? closeDay;

  AccountModel({
    required this.id,
    required this.name,
    required this.balance,
    this.currency = 'BRL',
    this.color = 0xFF6C63FF,
    this.type = 'checking',
    this.isActive = true,
    this.creditLimit,
    this.dueDay,
    this.closeDay,
  });

  double get availableCredit =>
      creditLimit != null ? creditLimit! - balance : 0;
  bool get isCreditCard => type == 'credit';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'currency': currency,
      'color': color,
      'type': type,
      'isActive': isActive,
      'creditLimit': creditLimit,
      'dueDay': dueDay,
      'closeDay': closeDay,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      name: map['name'],
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'] ?? 'BRL',
      color: map['color'] ?? 0xFF6C63FF,
      type: map['type'] ?? 'checking',
      isActive: map['isActive'] ?? true,
      creditLimit: map['creditLimit']?.toDouble(),
      dueDay: map['dueDay'],
      closeDay: map['closeDay'],
    );
  }
}
