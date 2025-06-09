import 'meal.dart';

class DailyMealPlan {
  final DateTime date;
  final List<Meal> breakfast;
  final List<Meal> lunch;
  final List<Meal> dinner;
  final List<Meal> snacks;
  final double targetCalories;
  final bool isCompleted;

  DailyMealPlan({
    required this.date,
    this.breakfast = const [],
    this.lunch = const [],
    this.dinner = const [],
    this.snacks = const [],
    this.targetCalories = 2000.0,
    this.isCompleted = false,
  });

  double get totalCalories {
    return breakfast.fold(0.0, (sum, meal) => sum + meal.calories) +
           lunch.fold(0.0, (sum, meal) => sum + meal.calories) +
           dinner.fold(0.0, (sum, meal) => sum + meal.calories) +
           snacks.fold(0.0, (sum, meal) => sum + meal.calories);
  }

  double get calorieProgress => totalCalories / targetCalories;

  bool get isOverTarget => totalCalories > targetCalories;

  DailyMealPlan copyWith({
    DateTime? date,
    List<Meal>? breakfast,
    List<Meal>? lunch,
    List<Meal>? dinner,
    List<Meal>? snacks,
    double? targetCalories,
    bool? isCompleted,
  }) {
    return DailyMealPlan(
      date: date ?? this.date,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
      targetCalories: targetCalories ?? this.targetCalories,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'breakfast': breakfast.map((meal) => meal.toJson()).toList(),
      'lunch': lunch.map((meal) => meal.toJson()).toList(),
      'dinner': dinner.map((meal) => meal.toJson()).toList(),
      'snacks': snacks.map((meal) => meal.toJson()).toList(),
      'targetCalories': targetCalories,
      'isCompleted': isCompleted,
    };
  }

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      breakfast: (json['breakfast'] as List).map((meal) => Meal.fromJson(meal)).toList(),
      lunch: (json['lunch'] as List).map((meal) => Meal.fromJson(meal)).toList(),
      dinner: (json['dinner'] as List).map((meal) => Meal.fromJson(meal)).toList(),
      snacks: (json['snacks'] as List).map((meal) => Meal.fromJson(meal)).toList(),
      targetCalories: json['targetCalories']?.toDouble() ?? 2000.0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
} 