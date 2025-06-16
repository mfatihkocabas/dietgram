import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/daily_meal_plan.dart';
import '../models/meal.dart';
import '../models/ai_menu_suggestion.dart';
import '../services/ai_menu_service.dart';
import '../services/user_data_service.dart';

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
    
    // Seçilen gün için verileri Firebase'den yükle
    loadDailyMealsFromFirebase(selectedDay);
    
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
    
    // Firebase'e kaydet
    _saveDailyMealsToFirebase(dateKey);
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
    
    // Firebase'e kaydet
    _saveDailyMealsToFirebase(dateKey);
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

  final AIMenuService _aiMenuService = AIMenuService();

  Future<void> generateAISuggestions({bool isPremium = false}) async {
    print('🔄 Starting AI suggestions generation...');
    
    try {
      // AI service'den menü önerileri al
      final suggestions = await _aiMenuService.generateMenuSuggestions(
        isPremium: isPremium,
        targetCalories: 2000,
        dietaryPreferences: "Dengeli beslenme",
      );

      if (suggestions != null && suggestions.isNotEmpty) {
        print('✅ AI suggestions received: ${suggestions.length} menu(s)');
        _aiSuggestions = suggestions;
        
        // AI önerilerini Firebase'e kaydet
        for (final suggestion in suggestions) {
          await saveAIMenuSuggestion(suggestion, _selectedDay);
        }
      } else {
        print('⚠️ No AI suggestions received, using fallback');
        // Fallback: Mock data kullan
        _generateMockSuggestions();
      }
    } catch (e) {
      print('❌ AI Suggestions Error: $e');
      // Hata durumunda mock data kullan
      _generateMockSuggestions();
    }
    
    print('🔔 Notifying listeners with ${_aiSuggestions.length} suggestions');
    notifyListeners();
  }

  /// Cooldown kontrolü
  bool canRequestNewSuggestions() {
    return _aiMenuService.canMakeRequest();
  }

  /// Kalan cooldown süresi
  int getRemainingCooldown() {
    return _aiMenuService.getRemainingCooldown();
  }

  /// AI suggestions'ı temizle
  void clearAISuggestions() {
    _aiSuggestions.clear();
    notifyListeners();
  }

  void _generateMockSuggestions() {
    _aiSuggestions = [
      AIMenuSuggestion.create(
        title: "Akdeniz Diyeti Menüsü",
        description: "Sağlıklı yağlar, taze sebzeler ve protein açısından zengin",
        meals: [
          Meal(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: "Meyveli Yulaf Ezmesi",
            mealType: "breakfast",
            calories: 280,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 8, 0),
            createdAt: DateTime.now(),
            description: "Yulaf ezmesi üzerine taze meyveler ve bal",
            ingredients: ["Yulaf ezmesi", "Yaban mersini", "Çilek", "Bal"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            name: "Akdeniz Kinoa Kasesi",
            mealType: "lunch",
            calories: 420,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 12, 30),
            createdAt: DateTime.now(),
            description: "Kinoa ile ızgara tavuk, sebzeler ve tzatziki",
            ingredients: ["Kinoa", "Izgara tavuk", "Salatalık", "Domates", "Tzatziki"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
            name: "Sebzeli Izgara Somon",
            mealType: "dinner",
            calories: 380,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 19, 0),
            createdAt: DateTime.now(),
            description: "Izgara somon ile közlenmiş Akdeniz sebzeleri",
            ingredients: ["Somon", "Kabak", "Biber", "Zeytinyağı"],
          ),
        ],
        dietaryTags: ["Akdeniz", "Yüksek Protein", "Kalp Dostu"],
        healthScore: 9.2,
        reasonForSuggestion: "Dengeli beslenme ve sağlıklı yaşam için ideal",
      ),
      AIMenuSuggestion.create(
        title: "Türk Mutfağı Menüsü",
        description: "Geleneksel Türk lezzetleri ile sağlıklı beslenme",
        meals: [
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
            name: "Peynirli Menemen",
            mealType: "breakfast",
            calories: 320,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 8, 0),
            createdAt: DateTime.now(),
            description: "Domates, biber ve peynirle hazırlanan menemen",
            ingredients: ["Yumurta", "Domates", "Biber", "Beyaz peynir"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
            name: "Mercimek Çorbası ve Salata",
            mealType: "lunch",
            calories: 380,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 12, 30),
            createdAt: DateTime.now(),
            description: "Kırmızı mercimek çorbası ile mevsim salatası",
            ingredients: ["Kırmızı mercimek", "Soğan", "Havuç", "Yeşillik"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 5).toString(),
            name: "Izgara Köfte ve Pilav",
            mealType: "dinner",
            calories: 450,
            date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 19, 0),
            createdAt: DateTime.now(),
            description: "Izgara köfte ile bulgur pilavı",
            ingredients: ["Dana kıyma", "Bulgur", "Soğan", "Maydanoz"],
          ),
        ],
        dietaryTags: ["Türk Mutfağı", "Geleneksel", "Lezzetli"],
        healthScore: 8.8,
        reasonForSuggestion: "Türk damak tadına uygun sağlıklı seçenekler",
      ),
    ];
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

    // AI suggestions will be generated when needed
  }

  // Firebase veri kaydetme metodları
  Future<void> _saveDailyMealsToFirebase(DateTime date) async {
    try {
      final plan = _mealPlans[date];
      if (plan == null) return;

      final meals = <Map<String, dynamic>>[];
      
      // Tüm yemekleri topla
      for (final meal in plan.breakfast) {
        meals.add(_mealToMap(meal));
      }
      for (final meal in plan.lunch) {
        meals.add(_mealToMap(meal));
      }
      for (final meal in plan.dinner) {
        meals.add(_mealToMap(meal));
      }
      for (final meal in plan.snacks) {
        meals.add(_mealToMap(meal));
      }

      // Makro besinleri hesapla
      final macros = _calculateMacros(meals);

      // Firebase'e kaydet
      await UserDataService.saveDailyMeals(
        date: date,
        meals: meals,
        totalCalories: plan.totalCalories.round(),
        macros: macros,
      );
      
      print('✅ Daily meals saved to Firebase for ${date.toString().split(' ')[0]}');
    } catch (e) {
      print('❌ Error saving daily meals to Firebase: $e');
    }
  }

  Map<String, dynamic> _mealToMap(Meal meal) {
    return {
      'id': meal.id,
      'name': meal.name,
      'mealType': meal.mealType,
      'calories': meal.calories,
      'description': meal.description,
      'ingredients': meal.ingredients,
      'timestamp': meal.timestamp.toIso8601String(),
      'createdAt': meal.createdAt.toIso8601String(),
    };
  }

  Map<String, double> _calculateMacros(List<Map<String, dynamic>> meals) {
    // Basit makro hesaplama (gerçek uygulamada daha detaylı olabilir)
    double totalCalories = meals.fold(0.0, (sum, meal) => sum + (meal['calories'] ?? 0));
    
    return {
      'protein': totalCalories * 0.25 / 4, // %25 protein (4 cal/g)
      'carbs': totalCalories * 0.45 / 4,   // %45 karbonhidrat (4 cal/g)
      'fat': totalCalories * 0.30 / 9,     // %30 yağ (9 cal/g)
    };
  }

  // AI menü önerisini Firebase'e kaydet
  Future<void> saveAIMenuSuggestion(AIMenuSuggestion suggestion, DateTime date) async {
    try {
      final menuData = {
        'title': suggestion.title,
        'description': suggestion.description,
        'healthScore': suggestion.healthScore,
        'dietaryTags': suggestion.dietaryTags,
        'reasonForSuggestion': suggestion.reasonForSuggestion,
        'meals': suggestion.meals.map((meal) => _mealToMap(meal)).toList(),
      };

      await UserDataService.saveAIMenuSuggestion(
        date: date,
        menuData: menuData,
      );
      
      print('✅ AI menu suggestion saved to Firebase');
    } catch (e) {
      print('❌ Error saving AI menu suggestion: $e');
    }
  }

  // Firebase'den günlük yemekleri yükle
  Future<void> loadDailyMealsFromFirebase(DateTime date) async {
    try {
      final data = await UserDataService.getDailyMeals(date);
      
      if (data != null) {
        final dateKey = DateTime(date.year, date.month, date.day);
        final meals = (data['meals'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        
        final breakfast = <Meal>[];
        final lunch = <Meal>[];
        final dinner = <Meal>[];
        final snacks = <Meal>[];

        for (final mealData in meals) {
          final meal = _mealFromMap(mealData);
          switch (meal.mealType.toLowerCase()) {
            case 'breakfast':
              breakfast.add(meal);
              break;
            case 'lunch':
              lunch.add(meal);
              break;
            case 'dinner':
              dinner.add(meal);
              break;
            case 'snack':
              snacks.add(meal);
              break;
          }
        }

        _mealPlans[dateKey] = DailyMealPlan(
          date: dateKey,
          breakfast: breakfast,
          lunch: lunch,
          dinner: dinner,
          snacks: snacks,
          targetCalories: 2000, // Default değer
        );

        notifyListeners();
        print('✅ Daily meals loaded from Firebase for ${date.toString().split(' ')[0]}');
      }
    } catch (e) {
      print('❌ Error loading daily meals from Firebase: $e');
    }
  }

  Meal _mealFromMap(Map<String, dynamic> data) {
    return Meal(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      mealType: data['mealType'] ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      ingredients: (data['ingredients'] as List<dynamic>?)?.cast<String>() ?? [],
      date: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
} 