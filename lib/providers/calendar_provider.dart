import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/daily_meal_plan.dart';
import '../models/meal.dart';
import '../models/ai_menu_suggestion.dart';

class CalendarProvider with ChangeNotifier {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, DailyMealPlan> _mealPlans = {};
  List<AIMenuSuggestion> _aiSuggestions = [];

  // Meal calorie limits per meal type
  static const Map<String, double> mealCalorieLimits = {
    'breakfast': 500.0,
    'lunch': 700.0,
    'dinner': 600.0,
    'snack': 200.0,
  };

  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  CalendarFormat get calendarFormat => _calendarFormat;
  Map<DateTime, DailyMealPlan> get mealPlans => _mealPlans;
  List<AIMenuSuggestion> get aiSuggestions => _aiSuggestions;

  DailyMealPlan? get selectedDayPlan {
    final dateKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    return _mealPlans[dateKey];
  }

  // Get meals for selected day by type
  List<Meal> getMealsForSelectedDay() {
    final plan = selectedDayPlan;
    if (plan == null) return [];
    
    List<Meal> allMeals = [];
    allMeals.addAll(plan.breakfast);
    allMeals.addAll(plan.lunch);
    allMeals.addAll(plan.dinner);
    allMeals.addAll(plan.snacks);
    
    // Sort by timestamp
    allMeals.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return allMeals;
  }

  // Check if meal exceeds calorie limit for its type
  bool exceedsMealLimit(String mealType, double currentCalories, double newMealCalories) {
    final limit = mealCalorieLimits[mealType.toLowerCase()] ?? 500.0;
    return (currentCalories + newMealCalories) > limit;
  }

  // Get current calories for a meal type on selected day
  double getCurrentMealCalories(String mealType) {
    final plan = selectedDayPlan;
    if (plan == null) return 0.0;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return plan.breakfast.fold(0.0, (sum, meal) => sum + meal.calories);
      case 'lunch':
        return plan.lunch.fold(0.0, (sum, meal) => sum + meal.calories);
      case 'dinner':
        return plan.dinner.fold(0.0, (sum, meal) => sum + meal.calories);
      case 'snack':
        return plan.snacks.fold(0.0, (sum, meal) => sum + meal.calories);
      default:
        return 0.0;
    }
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void setCalendarFormat(CalendarFormat format) {
    _calendarFormat = format;
    notifyListeners();
  }

  void addMealToPlan(DateTime date, String mealType, Meal meal) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final existingPlan = _mealPlans[dateKey] ?? DailyMealPlan(date: dateKey);

    // Check calorie limits
    final currentCalories = getCurrentMealCalories(mealType);
    if (exceedsMealLimit(mealType, currentCalories, meal.calories)) {
      // You can add a warning mechanism here if needed
    }

    List<Meal> updatedMeals;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        updatedMeals = [...existingPlan.breakfast, meal];
        _mealPlans[dateKey] = existingPlan.copyWith(breakfast: updatedMeals);
        break;
      case 'lunch':
        updatedMeals = [...existingPlan.lunch, meal];
        _mealPlans[dateKey] = existingPlan.copyWith(lunch: updatedMeals);
        break;
      case 'dinner':
        updatedMeals = [...existingPlan.dinner, meal];
        _mealPlans[dateKey] = existingPlan.copyWith(dinner: updatedMeals);
        break;
      case 'snack':
        updatedMeals = [...existingPlan.snacks, meal];
        _mealPlans[dateKey] = existingPlan.copyWith(snacks: updatedMeals);
        break;
    }
    notifyListeners();
  }

  void removeMealFromPlan(DateTime date, String mealType, String mealId) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final existingPlan = _mealPlans[dateKey];
    if (existingPlan == null) return;

    List<Meal> updatedMeals;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        updatedMeals = existingPlan.breakfast.where((meal) => meal.id != mealId).toList();
        _mealPlans[dateKey] = existingPlan.copyWith(breakfast: updatedMeals);
        break;
      case 'lunch':
        updatedMeals = existingPlan.lunch.where((meal) => meal.id != mealId).toList();
        _mealPlans[dateKey] = existingPlan.copyWith(lunch: updatedMeals);
        break;
      case 'dinner':
        updatedMeals = existingPlan.dinner.where((meal) => meal.id != mealId).toList();
        _mealPlans[dateKey] = existingPlan.copyWith(dinner: updatedMeals);
        break;
      case 'snack':
        updatedMeals = existingPlan.snacks.where((meal) => meal.id != mealId).toList();
        _mealPlans[dateKey] = existingPlan.copyWith(snacks: updatedMeals);
        break;
    }
    notifyListeners();
  }

  void setTargetCalories(DateTime date, double targetCalories) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final existingPlan = _mealPlans[dateKey] ?? DailyMealPlan(date: dateKey);
    _mealPlans[dateKey] = existingPlan.copyWith(targetCalories: targetCalories);
    notifyListeners();
  }

  void markDayCompleted(DateTime date, bool isCompleted) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final existingPlan = _mealPlans[dateKey] ?? DailyMealPlan(date: dateKey);
    _mealPlans[dateKey] = existingPlan.copyWith(isCompleted: isCompleted);
    notifyListeners();
  }

  void generateAISuggestions() {
    // Enhanced AI suggestions with better meal distribution
    _aiSuggestions = [
      AIMenuSuggestion.create(
        title: "Balanced Mediterranean Day",
        description: "Rich in healthy fats, lean proteins, and fresh vegetables",
        meals: [
          Meal(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: "Greek Yogurt with Berries",
            mealType: "breakfast",
            calories: 280,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 8, 0),
            createdAt: DateTime.now(),
            description: "Greek yogurt topped with mixed berries and honey",
            ingredients: ["Greek yogurt", "Blueberries", "Strawberries", "Honey"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            name: "Mediterranean Quinoa Bowl",
            mealType: "lunch",
            calories: 420,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 12, 30),
            createdAt: DateTime.now(),
            description: "Quinoa with grilled chicken, vegetables, and tzatziki",
            ingredients: ["Quinoa", "Grilled chicken", "Cucumber", "Tomato", "Tzatziki"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
            name: "Grilled Salmon with Vegetables",
            mealType: "dinner",
            calories: 380,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 19, 0),
            createdAt: DateTime.now(),
            description: "Grilled salmon with roasted Mediterranean vegetables",
            ingredients: ["Salmon", "Zucchini", "Bell peppers", "Olive oil"],
          ),
        ],
        dietaryTags: ["Mediterranean", "High Protein", "Heart Healthy"],
        healthScore: 9.2,
        reasonForSuggestion: "Based on your preference for balanced meals with good protein sources",
      ),
      AIMenuSuggestion.create(
        title: "Plant-Based Power Day",
        description: "High in fiber, vitamins, and plant-based proteins",
        meals: [
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
            name: "Overnight Oats with Chia",
            mealType: "breakfast",
            calories: 320,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 8, 0),
            createdAt: DateTime.now(),
            description: "Oats soaked with chia seeds, almond milk, and fruit",
            ingredients: ["Rolled oats", "Chia seeds", "Almond milk", "Banana"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
            name: "Lentil Buddha Bowl",
            mealType: "lunch",
            calories: 450,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 12, 30),
            createdAt: DateTime.now(),
            description: "Red lentils with roasted vegetables and tahini dressing",
            ingredients: ["Red lentils", "Sweet potato", "Kale", "Tahini"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 5).toString(),
            name: "Chickpea Curry",
            mealType: "dinner",
            calories: 380,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 19, 0),
            createdAt: DateTime.now(),
            description: "Spiced chickpea curry with brown rice",
            ingredients: ["Chickpeas", "Coconut milk", "Spinach", "Brown rice"],
          ),
        ],
        dietaryTags: ["Vegan", "High Fiber", "Plant-Based"],
        healthScore: 8.8,
        reasonForSuggestion: "Perfect for increasing your daily fiber and plant nutrients",
      ),
    ];
    notifyListeners();
  }

  void applyAISuggestion(AIMenuSuggestion suggestion, DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final existingPlan = _mealPlans[dateKey] ?? DailyMealPlan(date: dateKey);

    List<Meal> breakfast = [];
    List<Meal> lunch = [];
    List<Meal> dinner = [];
    List<Meal> snacks = [];

    for (final meal in suggestion.meals) {
      // Update meal timestamp to selected date
      final updatedMeal = meal.copyWith(
        date: DateTime(date.year, date.month, date.day, 
          meal.timestamp.hour, meal.timestamp.minute),
      );
      
      switch (meal.type.toLowerCase()) {
        case 'breakfast':
          breakfast.add(updatedMeal);
          break;
        case 'lunch':
          lunch.add(updatedMeal);
          break;
        case 'dinner':
          dinner.add(updatedMeal);
          break;
        case 'snack':
          snacks.add(updatedMeal);
          break;
      }
    }

    _mealPlans[dateKey] = existingPlan.copyWith(
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snacks: snacks,
    );
    notifyListeners();
  }

  // Calendar event markers
  List<DailyMealPlan> getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final plan = _mealPlans[dateKey];
    return plan != null ? [plan] : [];
  }

  // Statistics
  Map<String, double> getWeeklyStats(DateTime startOfWeek) {
    double totalCalories = 0;
    double avgCalories = 0;
    int daysWithData = 0;

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      final plan = _mealPlans[dateKey];
      if (plan != null) {
        totalCalories += plan.totalCalories;
        daysWithData++;
      }
    }

    if (daysWithData > 0) {
      avgCalories = totalCalories / daysWithData;
    }

    return {
      'totalCalories': totalCalories,
      'avgCalories': avgCalories,
      'daysWithData': daysWithData.toDouble(),
    };
  }

  void initializeSampleData() {
    // Sample data for demonstration
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    
    _mealPlans[todayKey] = DailyMealPlan(
      date: todayKey,
      breakfast: [
        Meal(
          id: "sample_1",
          name: "Oatmeal with Fruits",
          mealType: "breakfast",
          calories: 280,
          date: DateTime(today.year, today.month, today.day, 8, 0),
          createdAt: DateTime.now(),
          description: "Healthy oatmeal topped with fresh fruits",
          ingredients: ["Oats", "Banana", "Blueberries", "Honey"],
        ),
      ],
      lunch: [
        Meal(
          id: "sample_2",
          name: "Grilled Chicken Salad",
          mealType: "lunch",
          calories: 420,
          date: DateTime(today.year, today.month, today.day, 12, 30),
          createdAt: DateTime.now(),
          description: "Fresh salad with grilled chicken breast",
          ingredients: ["Chicken breast", "Mixed greens", "Tomato", "Cucumber"],
        ),
      ],
      targetCalories: 2000,
    );

    generateAISuggestions();
  }
} 