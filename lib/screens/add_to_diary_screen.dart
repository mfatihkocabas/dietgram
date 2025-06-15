import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/meal_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/meal.dart';
import '../main.dart'; // AuthService için
import '../services/ai_nutrition_service.dart';
import '../services/localization_service.dart';
import '../services/premium_service.dart';
import '../services/ad_service.dart';
import '../screens/premium_screen.dart';

class AddToDiaryScreen extends StatefulWidget {
  const AddToDiaryScreen({super.key});

  @override
  State<AddToDiaryScreen> createState() => _AddToDiaryScreenState();
}

class _AddToDiaryScreenState extends State<AddToDiaryScreen> {
  String? selectedMealType;
  DateTime selectedDate = DateTime.now();
  final AINutritionService _aiService = AINutritionService();

  List<Map<String, dynamic>> _getLocalizedMealOptions(String mealType, LocalizationService localization) {
    switch (mealType) {
      case 'breakfast':
        return [
          {
            'name': localization.getString('mealOatmealBerries'),
            'calories': 280.0,
            'description': localization.getString('mealOatmealBerriesDesc'),
            'ingredients': ['Rolled oats', 'Blueberries', 'Strawberries', 'Honey'],
          },
          {
            'name': localization.getString('mealGreekYogurt'),
            'calories': 220.0,
            'description': localization.getString('mealGreekYogurtDesc'),
            'ingredients': ['Greek yogurt', 'Granola', 'Banana', 'Honey'],
          },
          {
            'name': localization.getString('mealAvocadoToast'),
            'calories': 320.0,
            'description': localization.getString('mealAvocadoToastDesc'),
            'ingredients': ['Whole grain bread', 'Avocado', 'Salt', 'Pepper'],
          },
          {
            'name': localization.getString('mealScrambledEggs'),
            'calories': 250.0,
            'description': localization.getString('mealScrambledEggsDesc'),
            'ingredients': ['Eggs', 'Milk', 'Herbs', 'Butter'],
          },
        ];
      case 'lunch':
        return [
          {
            'name': localization.getString('mealGrilledChickenSalad'),
            'calories': 420.0,
            'description': localization.getString('mealGrilledChickenSaladDesc'),
            'ingredients': ['Chicken breast', 'Mixed greens', 'Tomato', 'Cucumber'],
          },
          {
            'name': localization.getString('mealQuinoaBowl'),
            'calories': 380.0,
            'description': localization.getString('mealQuinoaBowlDesc'),
            'ingredients': ['Quinoa', 'Bell peppers', 'Zucchini', 'Tahini'],
          },
          {
            'name': localization.getString('mealTurkeySandwich'),
            'calories': 350.0,
            'description': localization.getString('mealTurkeySandwichDesc'),
            'ingredients': ['Whole grain bread', 'Turkey', 'Lettuce', 'Tomato'],
          },
          {
            'name': localization.getString('mealLentilSoup'),
            'calories': 280.0,
            'description': localization.getString('mealLentilSoupDesc'),
            'ingredients': ['Red lentils', 'Carrots', 'Onions', 'Vegetable broth'],
          },
        ];
      case 'dinner':
        return [
          {
            'name': localization.getString('mealGrilledSalmon'),
            'calories': 450.0,
            'description': localization.getString('mealGrilledSalmonDesc'),
            'ingredients': ['Salmon fillet', 'Broccoli', 'Sweet potato', 'Olive oil'],
          },
          {
            'name': localization.getString('mealChickenStirFry'),
            'calories': 380.0,
            'description': localization.getString('mealChickenStirFryDesc'),
            'ingredients': ['Chicken breast', 'Bell peppers', 'Broccoli', 'Soy sauce'],
          },
          {
            'name': localization.getString('mealVegetableCurry'),
            'calories': 320.0,
            'description': localization.getString('mealVegetableCurryDesc'),
            'ingredients': ['Mixed vegetables', 'Coconut milk', 'Curry spices', 'Rice'],
          },
          {
            'name': localization.getString('mealPastaPrimavera'),
            'calories': 410.0,
            'description': localization.getString('mealPastaPrimaveraDesc'),
            'ingredients': ['Whole grain pasta', 'Zucchini', 'Cherry tomatoes', 'Basil'],
          },
        ];
      case 'snack':
        return [
          {
            'name': localization.getString('mealMixedNuts'),
            'calories': 180.0,
            'description': localization.getString('mealMixedNutsDesc'),
            'ingredients': ['Almonds', 'Walnuts', 'Cashews'],
          },
          {
            'name': localization.getString('mealApplePeanutButter'),
            'calories': 190.0,
            'description': localization.getString('mealApplePeanutButterDesc'),
            'ingredients': ['Apple', 'Peanut butter'],
          },
          {
            'name': localization.getString('mealProteinSmoothie'),
            'calories': 250.0,
            'description': localization.getString('mealProteinSmoothieDesc'),
            'ingredients': ['Protein powder', 'Banana', 'Berries', 'Almond milk'],
          },
          {
            'name': localization.getString('mealHummusVegetables'),
            'calories': 150.0,
            'description': localization.getString('mealHummusVegetablesDesc'),
            'ingredients': ['Hummus', 'Carrots', 'Cucumbers', 'Bell peppers'],
          },
        ];
      default:
        return [];
    }
  }

  final Map<String, List<Map<String, dynamic>>> mealOptions = {
    'breakfast': [
      {
        'name': 'Oatmeal with Berries',
        'calories': 280.0,
        'description': 'Rolled oats with mixed berries and honey',
        'ingredients': ['Rolled oats', 'Blueberries', 'Strawberries', 'Honey'],
      },
      {
        'name': 'Greek Yogurt Parfait',
        'calories': 220.0,
        'description': 'Greek yogurt layered with granola and fruit',
        'ingredients': ['Greek yogurt', 'Granola', 'Banana', 'Honey'],
      },
      {
        'name': 'Avocado Toast',
        'calories': 320.0,
        'description': 'Whole grain toast with smashed avocado',
        'ingredients': ['Whole grain bread', 'Avocado', 'Salt', 'Pepper'],
      },
      {
        'name': 'Scrambled Eggs',
        'calories': 250.0,
        'description': 'Two eggs scrambled with herbs',
        'ingredients': ['Eggs', 'Milk', 'Herbs', 'Butter'],
      },
    ],
    'lunch': [
      {
        'name': 'Grilled Chicken Salad',
        'calories': 420.0,
        'description': 'Mixed greens with grilled chicken breast',
        'ingredients': ['Chicken breast', 'Mixed greens', 'Tomato', 'Cucumber'],
      },
      {
        'name': 'Quinoa Bowl',
        'calories': 380.0,
        'description': 'Quinoa with roasted vegetables and tahini',
        'ingredients': ['Quinoa', 'Bell peppers', 'Zucchini', 'Tahini'],
      },
      {
        'name': 'Turkey Sandwich',
        'calories': 350.0,
        'description': 'Whole grain sandwich with turkey and vegetables',
        'ingredients': ['Whole grain bread', 'Turkey', 'Lettuce', 'Tomato'],
      },
      {
        'name': 'Lentil Soup',
        'calories': 280.0,
        'description': 'Hearty lentil soup with vegetables',
        'ingredients': ['Red lentils', 'Carrots', 'Onions', 'Vegetable broth'],
      },
    ],
    'dinner': [
      {
        'name': 'Grilled Salmon',
        'calories': 450.0,
        'description': 'Grilled salmon with roasted vegetables',
        'ingredients': ['Salmon fillet', 'Broccoli', 'Sweet potato', 'Olive oil'],
      },
      {
        'name': 'Chicken Stir Fry',
        'calories': 380.0,
        'description': 'Chicken with mixed vegetables in light sauce',
        'ingredients': ['Chicken breast', 'Bell peppers', 'Broccoli', 'Soy sauce'],
      },
      {
        'name': 'Vegetable Curry',
        'calories': 320.0,
        'description': 'Mixed vegetables in coconut curry sauce',
        'ingredients': ['Mixed vegetables', 'Coconut milk', 'Curry spices', 'Rice'],
      },
      {
        'name': 'Pasta Primavera',
        'calories': 410.0,
        'description': 'Whole grain pasta with seasonal vegetables',
        'ingredients': ['Whole grain pasta', 'Zucchini', 'Cherry tomatoes', 'Basil'],
      },
    ],
    'snack': [
      {
        'name': 'Mixed Nuts',
        'calories': 180.0,
        'description': 'A handful of mixed nuts',
        'ingredients': ['Almonds', 'Walnuts', 'Cashews'],
      },
      {
        'name': 'Apple with Peanut Butter',
        'calories': 190.0,
        'description': 'Sliced apple with natural peanut butter',
        'ingredients': ['Apple', 'Peanut butter'],
      },
      {
        'name': 'Protein Smoothie',
        'calories': 250.0,
        'description': 'Protein smoothie with fruits',
        'ingredients': ['Protein powder', 'Banana', 'Berries', 'Almond milk'],
      },
      {
        'name': 'Hummus with Vegetables',
        'calories': 150.0,
        'description': 'Fresh vegetables with hummus dip',
        'ingredients': ['Hummus', 'Carrots', 'Cucumbers', 'Bell peppers'],
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              localization.getString('addToDiaryTitle'),
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                _showDatePicker(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGray,
                foregroundColor: AppColors.textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _formatDate(selectedDate, localization),
                style: GoogleFonts.epilogue(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: selectedMealType == null
          ? _buildMealTypeSelection(localization)
          : _buildMealOptionsGrid(localization),
      floatingActionButton: selectedMealType != null 
        ? Consumer<PremiumService>(
            builder: (context, premiumService, child) {
              return FloatingActionButton.extended(
                onPressed: () => _navigateToCustomMeal(premiumService),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  localization.getString('addToDiaryAddCustomMeal'),
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              );
            },
          )
        : null,
    );
      },
    );
  }

  Widget _buildMealTypeSelection(LocalizationService localization) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.primary.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.getString('addToDiarySelectMealType'),
                        style: GoogleFonts.epilogue(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localization.getStringWithParams('addToDiaryChooseMeal', {'date': _formatDate(selectedDate, localization)}),
                        style: GoogleFonts.epilogue(
                          fontSize: 16,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildMealTypeCard(localization.getString('mealTypeBreakfast'), Icons.wb_sunny, 'breakfast', localization.getString('addToDiaryBreakfastTime'), localization),
                _buildMealTypeCard(localization.getString('mealTypeLunch'), Icons.lunch_dining, 'lunch', localization.getString('addToDiaryLunchTime'), localization),
                _buildMealTypeCard(localization.getString('mealTypeDinner'), Icons.dinner_dining, 'dinner', localization.getString('addToDiaryDinnerTime'), localization),
                _buildMealTypeCard(localization.getString('mealTypeSnack'), Icons.cookie, 'snack', localization.getString('addToDiarySnackTime'), localization),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeCard(String title, IconData icon, String type, String timeRange, LocalizationService localization) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMealType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeRange,
              style: GoogleFonts.epilogue(
                fontSize: 11,
                color: AppColors.textMedium,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealOptionsGrid(LocalizationService localization) {
    final options = _getLocalizedMealOptions(selectedMealType!, localization);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedMealType = null;
                  });
                },
                icon: Icon(Icons.arrow_back, color: AppColors.textDark),
              ),
              Text(
                localization.getStringWithParams('addToDiaryOptionsTitle', {'mealType': _getMealTypeName(selectedMealType!, localization)}),
                style: GoogleFonts.epilogue(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return _buildMealOptionCard(option, localization);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMealOptionCard(Map<String, dynamic> option, LocalizationService localization) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  option['name'],
                  style: GoogleFonts.epilogue(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${option['calories'].toInt()} cal',
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            option['description'],
            style: GoogleFonts.epilogue(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: (option['ingredients'] as List<String>).map((ingredient) => 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ingredient,
                  style: GoogleFonts.epilogue(
                    fontSize: 10,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                                            onPressed: () async => await _addMealToCalendar(option, localization),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                localization.getStringWithParams('addToDiaryAddToDate', {'date': _formatDate(selectedDate, localization)}),
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addMealToCalendar(Map<String, dynamic> option, LocalizationService localization) async {
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    
    // Check calorie limits before adding
    final currentCalories = calendarProvider.getCurrentMealCalories(selectedMealType!);
    final newMealCalories = option['calories'];
    final limit = CalendarProvider.mealCalorieLimits[selectedMealType!.toLowerCase()] ?? 500.0;
    
    if (calendarProvider.exceedsMealLimit(selectedMealType!, currentCalories, newMealCalories)) {
      // Show warning dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            localization.getString('addToDiaryCalorieLimit'),
            style: GoogleFonts.epilogue(
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.getStringWithParams('addToDiaryCalorieLimitMessage', {'mealType': _getMealTypeName(selectedMealType!, localization)}),
                style: GoogleFonts.epilogue(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                localization.getStringWithParams('addToDiaryCurrent', {'calories': currentCalories.toInt().toString()}),
                style: GoogleFonts.epilogue(fontSize: 12, color: AppColors.textMedium),
              ),
              Text(
                localization.getStringWithParams('addToDiaryAdding', {'calories': newMealCalories.toInt().toString()}),
                style: GoogleFonts.epilogue(fontSize: 12, color: AppColors.textMedium),
              ),
              Text(
                localization.getStringWithParams('addToDiaryTotal', {'calories': (currentCalories + newMealCalories).toInt().toString()}),
                style: GoogleFonts.epilogue(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                localization.getStringWithParams('addToDiaryLimit', {'calories': limit.toInt().toString()}),
                style: GoogleFonts.epilogue(fontSize: 12, color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                localization.getString('cancel'),
                style: GoogleFonts.epilogue(color: AppColors.textMedium),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _proceedWithMealAddition(option, calendarProvider, localization);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                localization.getString('addToDiaryAddAnyway'),
                style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else {
      await _proceedWithMealAddition(option, calendarProvider, localization);
    }
  }

  Future<void> _proceedWithMealAddition(Map<String, dynamic> option, CalendarProvider calendarProvider, LocalizationService localization) async {
    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: option['name'],
      mealType: selectedMealType!,
      calories: option['calories'].toDouble(),
      date: selectedDate,
      createdAt: DateTime.now(),
      description: option['description'],
      ingredients: List<String>.from(option['ingredients']),
    );

    // Add to meal provider
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    await mealProvider.addMeal(meal);

    // Add to calendar provider
    calendarProvider.addMealToPlan(selectedDate, selectedMealType!, meal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localization.getStringWithParams('addToDiaryMealAdded', {'meal': option['name'], 'date': _formatDate(selectedDate, localization)}),
          style: GoogleFonts.epilogue(),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date, LocalizationService localization) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    
    if (selectedDay == today) {
      return localization.getString('dateToday');
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return localization.getString('dateTomorrow');
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return localization.getString('dateYesterday');
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  String _getMealTypeName(String mealType, LocalizationService localization) {
    switch (mealType) {
      case 'breakfast': return localization.getString('mealTypeBreakfast');
      case 'lunch': return localization.getString('mealTypeLunch');
      case 'dinner': return localization.getString('mealTypeDinner');
      case 'snack': return localization.getString('mealTypeSnack');
      default: return mealType;
    }
  }
  


  void _navigateToCustomMeal(PremiumService premiumService) {
    // Check if user can add custom meal
    if (!premiumService.canAddCustomMeal()) {
      _showPremiumLimitDialog(premiumService);
      return;
    }

            showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CustomMealBottomSheet(
            mealType: selectedMealType!,
            selectedDate: selectedDate,
            aiService: _aiService,
            parent: this,
          ),
        );
  }

  void _showPremiumLimitDialog(PremiumService premiumService) {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localization.getString('addToDiaryDailyLimitExceeded'),
          style: GoogleFonts.epilogue(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.getStringWithParams('addToDiaryDailyLimitMessage', {'limit': PremiumService.maxDailyCustomMeals.toString()}),
              style: GoogleFonts.epilogue(),
            ),
            const SizedBox(height: 12),
            Text(
              localization.getStringWithParams('addToDiaryDailyLimitUsage', {'used': premiumService.dailyCustomMealCount.toString(), 'limit': PremiumService.maxDailyCustomMeals.toString()}),
              style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              localization.getString('addToDiaryUpgradePremium'),
              style: GoogleFonts.epilogue(color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localization.getString('cancel'),
              style: GoogleFonts.epilogue(color: AppColors.textMedium),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              localization.getString('addToDiaryUpgradeButton'),
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Meal Bottom Sheet Widget
class CustomMealBottomSheet extends StatefulWidget {
  final String mealType;
  final DateTime selectedDate;
  final AINutritionService aiService;
  final _AddToDiaryScreenState parent;

  const CustomMealBottomSheet({
    super.key,
    required this.mealType,
    required this.selectedDate,
    required this.aiService,
    required this.parent,
  });

  @override
  State<CustomMealBottomSheet> createState() => _CustomMealBottomSheetState();
}

class _CustomMealBottomSheetState extends State<CustomMealBottomSheet> {
  final _mealNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isAnalyzing = false;
  NutritionEstimate? _nutritionEstimate;

  @override
  void dispose() {
    _mealNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _analyzeFood(LocalizationService localization) async {
    if (_descriptionController.text.trim().isEmpty) {
      _showSnackBar(Provider.of<LocalizationService>(context, listen: false).getString('enterFoodDescription'), isError: true);
      return;
    }

    // Check AI analysis limit for free users
    final premiumService = Provider.of<PremiumService>(context, listen: false);
    if (!premiumService.canUseAIAnalysis()) {
      _showAILimitDialog(premiumService, localization);
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _nutritionEstimate = null;
    });

    try {
      final estimate = await widget.aiService.analyzeFood(
        _descriptionController.text.trim(),
        isPremium: premiumService.isPremium,
      );
      
      // Increment AI analysis count for free users
      premiumService.incrementAIAnalysisCount();
      
      setState(() {
        _nutritionEstimate = estimate;
        if (estimate != null && _mealNameController.text.isEmpty) {
          _mealNameController.text = estimate.recognizedFood;
        }
      });
      _showSnackBar(Provider.of<LocalizationService>(context, listen: false).getString('aiAnalysisComplete'), isError: false);
    } catch (e) {
      _showSnackBar(Provider.of<LocalizationService>(context, listen: false).getString('analysisError'), isError: true);
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showAILimitDialog(PremiumService premiumService, LocalizationService localization) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localization.getString('addToDiaryAILimitTitle'),
          style: GoogleFonts.epilogue(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.getStringWithParams('addToDiaryAILimitMessage', {'limit': PremiumService.maxWeeklyAIAnalysis.toString()}),
              style: GoogleFonts.epilogue(),
            ),
            const SizedBox(height: 12),
            Text(
              localization.getStringWithParams('addToDiaryAILimitUsage', {'used': premiumService.weeklyAIAnalysisCount.toString(), 'limit': PremiumService.maxWeeklyAIAnalysis.toString()}),
              style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              localization.getString('addToDiaryAILimitUpgrade'),
              style: GoogleFonts.epilogue(color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localization.getString('cancel'),
              style: GoogleFonts.epilogue(color: AppColors.textMedium),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              localization.getString('addToDiaryUpgradeButton'),
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addMeal(LocalizationService localization) async {
    if (!_formKey.currentState!.validate()) return;
    if (_nutritionEstimate == null) {
      _showSnackBar(Provider.of<LocalizationService>(context, listen: false).getString('analysisRequired'), isError: true);
      return;
    }

    // Kalori sınırı kontrolü
    if (widget.aiService.checkMealCalorieLimit(widget.mealType, _nutritionEstimate!.nutrition.calories)) {
      _showCalorieWarningDialog(localization);
      return;
    }

    await _saveMeal();
  }

  Future<void> _saveMeal() async {
    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _mealNameController.text.trim(),
      description: _nutritionEstimate!.description,
      calories: _nutritionEstimate!.nutrition.calories,
      mealType: widget.mealType,
      ingredients: _nutritionEstimate!.ingredients,
      date: widget.selectedDate,
      createdAt: DateTime.now(),
      nutritionInfo: _nutritionEstimate!.nutrition.toMap(),
    );

    try {
      // Add to both providers
      Provider.of<MealProvider>(context, listen: false).addMeal(meal);
      
      // Add to calendar provider for the specific date and meal type
      Provider.of<CalendarProvider>(context, listen: false).addMealToPlan(
        widget.selectedDate, 
        widget.mealType, 
        meal
      );
      
      // Increment custom meal count for free users
      final premiumService = Provider.of<PremiumService>(context, listen: false);
      premiumService.incrementCustomMealCount();
      
      _showSnackBar(Provider.of<LocalizationService>(context, listen: false).getString('mealAddedSuccessfully'), isError: false);
      
      // Show interstitial ad for free users occasionally
      if (premiumService.showAds && premiumService.dailyCustomMealCount % 2 == 0) {
        AdService().showInterstitialAd();
      }
      
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar(Provider.of<LocalizationService>(context, listen: false).getString('mealAddError'), isError: true);
    }
  }

  void _showCalorieWarningDialog(LocalizationService localization) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.getString('addToDiaryCalorieWarning'), style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        content: Text(localization.getStringWithParams('addToDiaryCalorieWarningMessage', {'mealType': _getMealTypeName(widget.mealType, localization)})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.getString('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveMeal();
            },
            child: Text(localization.getString('addToDiaryAddAnyway')),
          ),
        ],
      ),
    );
  }

  String _getMealTypeName(String mealType, LocalizationService localization) {
    switch (mealType) {
      case 'breakfast': return localization.getString('mealTypeBreakfast');
      case 'lunch': return localization.getString('mealTypeLunch');
      case 'dinner': return localization.getString('mealTypeDinner');
      case 'snack': return localization.getString('mealTypeSnack');
      default: return mealType;
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Consumer<LocalizationService>(
            builder: (context, localization, child) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.getString('addToDiaryAddCustomMeal'),
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Content
          Expanded(
            child: Consumer<LocalizationService>(
              builder: (context, localization, child) {
                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Meal type indicator
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            _getMealTypeName(widget.mealType, localization),
                            style: GoogleFonts.epilogue(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description field
                    Text(
                      localization.getString('addToDiaryFoodDescription'),
                      style: GoogleFonts.epilogue(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: localization.getString('addToDiaryFoodDescriptionHint'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? localization.getString('addToDiaryDescriptionRequired') : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // AI Analysis button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : () => _analyzeFood(localization),
                        icon: _isAnalyzing 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.psychology, color: Colors.white),
                        label: Text(
                          _isAnalyzing ? localization.getString('addToDiaryAnalyzing') : localization.getString('addToDiaryAnalyzeWithAI'),
                          style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    if (_nutritionEstimate != null) ...[
                      const SizedBox(height: 24),
                      
                      // Analysis results
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.psychology, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  localization.getString('addToDiaryAIResult'),
                                  style: GoogleFonts.epilogue(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _nutritionEstimate!.recognizedFood,
                              style: GoogleFonts.epilogue(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Calorie highlight
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_fire_department, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    localization.getStringWithParams('addToDiaryCalories', {'calories': _nutritionEstimate!.nutrition.calories.round().toString()}),
                                    style: GoogleFonts.epilogue(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Meal name field
                      Text(
                        localization.getString('addToDiaryMealName'),
                        style: GoogleFonts.epilogue(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _mealNameController,
                        decoration: InputDecoration(
                          hintText: localization.getString('addToDiaryMealNameHint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? localization.getString('addToDiaryMealNameRequired') : null,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Add button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _addMeal(localization),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            localization.getString('addToDiaryAddToJournal'),
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
