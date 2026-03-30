import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 20)
class HabitModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String icon;

  @HiveField(4)
  int color;

  @HiveField(5)
  List<int> frequency;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  List<DateTime> completedDates;

  HabitModel({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.createdAt,
    List<DateTime>? completedDates,
  }) : completedDates = completedDates ?? [];

  bool isCompletedOn(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  int get currentStreak {
    int streak = 0;
    DateTime date = DateTime.now();

    if (!isCompletedOn(date)) {
      date = date.subtract(const Duration(days: 1));
    }

    while (isCompletedOn(date)) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int get totalCompletions => completedDates.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'frequency': frequency,
      'createdAt': createdAt.toIso8601String(),
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      color: map['color'],
      frequency: List<int>.from(map['frequency']),
      createdAt: DateTime.parse(map['createdAt']),
      completedDates: map['completedDates'] != null
          ? List<DateTime>.from(
              (map['completedDates'] as List).map((d) => DateTime.parse(d)),
            )
          : [],
    );
  }
}
