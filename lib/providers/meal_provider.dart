import 'package:flutter/material.dart';
import '../models/meal.dart';

class MealProvider extends ChangeNotifier {
  List<Meal> _meals = [];
  double _dailyGoal = 2000.0;

  List<Meal> get meals => _meals;
  double get dailyGoal => _dailyGoal;
  
  double get totalCalories {
    return _meals.fold(0.0, (sum, meal) => sum + meal.calories);
  }
  
  double get remainingCalories {
    return _dailyGoal - totalCalories;
  }

  List<Meal> getTodaysMeals() {
    final today = DateTime.now();
    return _meals.where((meal) {
      return meal.timestamp.day == today.day &&
             meal.timestamp.month == today.month &&
             meal.timestamp.year == today.year;
    }).toList();
  }

  List<Meal> getMealsForDate(DateTime date) {
    return _meals.where((meal) {
      return meal.timestamp.day == date.day &&
             meal.timestamp.month == date.month &&
             meal.timestamp.year == date.year;
    }).toList();
  }

  List<Meal> getMealsByType(String type) {
    return _meals.where((meal) => meal.type.toLowerCase() == type.toLowerCase()).toList();
  }

  void addMeal(Meal meal) {
    _meals.add(meal);
    notifyListeners();
  }

  void removeMeal(String id) {
    _meals.removeWhere((meal) => meal.id == id);
    notifyListeners();
  }

  void updateMeal(Meal updatedMeal) {
    final index = _meals.indexWhere((meal) => meal.id == updatedMeal.id);
    if (index != -1) {
      _meals[index] = updatedMeal;
      notifyListeners();
    }
  }

  void setDailyGoal(double goal) {
    _dailyGoal = goal;
    notifyListeners();
  }

  void loadSampleData() {
    _meals = [
      Meal(
        id: '1',
        name: 'Oatmeal with fruits',
        mealType: 'breakfast',
        calories: 350.0,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        description: 'Healthy breakfast with rolled oats and mixed berries',
        ingredients: ['Rolled oats', 'Blueberries', 'Strawberries', 'Honey'],
      ),
      Meal(
        id: '2',
        name: 'Grilled chicken salad',
        mealType: 'lunch',
        calories: 420.0,
        date: DateTime.now().subtract(const Duration(hours: 6)),
        createdAt: DateTime.now(),
        description: 'Fresh mixed greens with grilled chicken breast',
        ingredients: ['Chicken breast', 'Mixed greens', 'Tomato', 'Cucumber', 'Olive oil'],
      ),
      Meal(
        id: '3',
        name: 'Greek yogurt',
        mealType: 'snack',
        calories: 150.0,
        date: DateTime.now().subtract(const Duration(hours: 4)),
        createdAt: DateTime.now(),
        description: 'Plain Greek yogurt with a drizzle of honey',
        ingredients: ['Greek yogurt', 'Honey'],
      ),
    ];
    notifyListeners();
  }

  // Statistics methods
  Map<String, double> getWeeklyCalories() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    Map<String, double> weeklyData = {};

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayMeals = getMealsForDate(date);
      final totalCals = dayMeals.fold(0.0, (sum, meal) => sum + meal.calories);
      
      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];
      weeklyData[dayName] = totalCals;
    }

    return weeklyData;
  }

  double getAverageCalories() {
    if (_meals.isEmpty) return 0.0;
    
    final uniqueDates = _meals
        .map((meal) => DateTime(meal.timestamp.year, meal.timestamp.month, meal.timestamp.day))
        .toSet();
    
    if (uniqueDates.isEmpty) return 0.0;
    
    return totalCalories / uniqueDates.length;
  }
} 