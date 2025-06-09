import 'meal.dart';

class AIMenuSuggestion {
  final String id;
  final String title;
  final String description;
  final List<Meal> meals;
  final double totalCalories;
  final List<String> dietaryTags;
  final double healthScore;
  final String reasonForSuggestion;
  final DateTime createdAt;

  AIMenuSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.meals,
    required this.totalCalories,
    required this.dietaryTags,
    required this.healthScore,
    required this.reasonForSuggestion,
    required this.createdAt,
  });

  factory AIMenuSuggestion.create({
    required String title,
    required String description,
    required List<Meal> meals,
    required List<String> dietaryTags,
    required double healthScore,
    required String reasonForSuggestion,
  }) {
    return AIMenuSuggestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      meals: meals,
      totalCalories: meals.fold(0.0, (sum, meal) => sum + meal.calories),
      dietaryTags: dietaryTags,
      healthScore: healthScore,
      reasonForSuggestion: reasonForSuggestion,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'totalCalories': totalCalories,
      'dietaryTags': dietaryTags,
      'healthScore': healthScore,
      'reasonForSuggestion': reasonForSuggestion,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AIMenuSuggestion.fromJson(Map<String, dynamic> json) {
    return AIMenuSuggestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      meals: (json['meals'] as List).map((meal) => Meal.fromJson(meal)).toList(),
      totalCalories: json['totalCalories']?.toDouble() ?? 0.0,
      dietaryTags: List<String>.from(json['dietaryTags']),
      healthScore: json['healthScore']?.toDouble() ?? 0.0,
      reasonForSuggestion: json['reasonForSuggestion'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }
} 