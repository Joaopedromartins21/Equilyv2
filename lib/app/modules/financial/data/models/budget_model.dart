import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 5)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  double limitAmount;

  @HiveField(3)
  double spentAmount;

  @HiveField(4)
  int month;

  @HiveField(5)
  int year;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limitAmount,
    this.spentAmount = 0,
    required this.month,
    required this.year,
  });

  double get remaining => limitAmount - spentAmount;
  double get progress =>
      limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 1.0) : 0;
  bool get isOverBudget => spentAmount > limitAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      limitAmount: (map['limitAmount'] as num).toDouble(),
      spentAmount: (map['spentAmount'] as num?)?.toDouble() ?? 0,
      month: map['month'],
      year: map['year'],
    );
  }
}
