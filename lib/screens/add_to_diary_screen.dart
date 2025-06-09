import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/meal_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/meal.dart';

class AddToDiaryScreen extends StatefulWidget {
  const AddToDiaryScreen({super.key});

  @override
  State<AddToDiaryScreen> createState() => _AddToDiaryScreenState();
}

class _AddToDiaryScreenState extends State<AddToDiaryScreen> {
  String? selectedMealType;
  DateTime selectedDate = DateTime.now();

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
          'Add to Diary',
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
                _formatDate(selectedDate),
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
          ? _buildMealTypeSelection()
          : _buildMealOptionsGrid(),
    );
  }

  Widget _buildMealTypeSelection() {
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
                        'Select meal type',
                        style: GoogleFonts.epilogue(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose which meal to add to ${_formatDate(selectedDate)}',
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
                _buildMealTypeCard('Breakfast', Icons.wb_sunny, 'breakfast', '6-10 AM'),
                _buildMealTypeCard('Lunch', Icons.lunch_dining, 'lunch', '12-3 PM'),
                _buildMealTypeCard('Dinner', Icons.dinner_dining, 'dinner', '6-9 PM'),
                _buildMealTypeCard('Snack', Icons.cookie, 'snack', 'Anytime'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeCard(String title, IconData icon, String type, String timeRange) {
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

  Widget _buildMealOptionsGrid() {
    final options = mealOptions[selectedMealType] ?? [];
    
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
                '${selectedMealType![0].toUpperCase()}${selectedMealType!.substring(1)} Options',
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
              return _buildMealOptionCard(option);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMealOptionCard(Map<String, dynamic> option) {
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
              onPressed: () => _addMealToCalendar(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add to ${_formatDate(selectedDate)}',
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

  void _addMealToCalendar(Map<String, dynamic> option) {
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
            'Calorie Limit Warning',
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
                'Adding this meal will exceed the recommended calorie limit for ${selectedMealType!}.',
                style: GoogleFonts.epilogue(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'Current: ${currentCalories.toInt()} cal',
                style: GoogleFonts.epilogue(fontSize: 12, color: AppColors.textMedium),
              ),
              Text(
                'Adding: ${newMealCalories.toInt()} cal',
                style: GoogleFonts.epilogue(fontSize: 12, color: AppColors.textMedium),
              ),
              Text(
                'Total: ${(currentCalories + newMealCalories).toInt()} cal',
                style: GoogleFonts.epilogue(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                'Limit: ${limit.toInt()} cal',
                style: GoogleFonts.epilogue(fontSize: 12, color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.epilogue(color: AppColors.textMedium),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _proceedWithMealAddition(option, calendarProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Add Anyway',
                style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else {
      _proceedWithMealAddition(option, calendarProvider);
    }
  }

  void _proceedWithMealAddition(Map<String, dynamic> option, CalendarProvider calendarProvider) {
    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: option['name'],
      type: selectedMealType!,
      calories: option['calories'],
      timestamp: selectedDate,
      description: option['description'],
      ingredients: List<String>.from(option['ingredients']),
    );

    // Add to meal provider
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    mealProvider.addMeal(meal);

    // Add to calendar provider
    calendarProvider.addMealToPlan(selectedDate, selectedMealType!, meal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${option['name']} added to ${_formatDate(selectedDate)}',
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    
    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    }
  }
} 
