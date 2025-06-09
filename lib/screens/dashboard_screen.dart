import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/meal_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/meal.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Reset to home tab when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<MealProvider, CalendarProvider>(
          builder: (context, mealProvider, calendarProvider, child) {
            // Get meals for selected day from calendar
            final selectedDayMeals = calendarProvider.getMealsForSelectedDay();
            final selectedDate = calendarProvider.selectedDay;
            
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(selectedDate),
                        const SizedBox(height: 16),
                        _buildCalorieCards(selectedDayMeals, calendarProvider),
                      ],
                    ),
                  ),
                ),
                
                // Timeline Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Timeline',
                            style: GoogleFonts.epilogue(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/calendar').then((_) {
                              // Reset to home tab when returning from calendar
                              setState(() {
                                _currentIndex = 0;
                              });
                            });
                          },
                          child: Text(
                            'View Calendar',
                            style: GoogleFonts.epilogue(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Timeline Content
                selectedDayMeals.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildEmptyState(calendarProvider),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildMealTimelineItem(
                                selectedDayMeals[index],
                                index == selectedDayMeals.length - 1,
                              ),
                            );
                          },
                          childCount: selectedDayMeals.length,
                        ),
                      ),
                
                // Bottom padding for FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-to-diary');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(DateTime selectedDate) {
    final isToday = DateTime.now().day == selectedDate.day &&
                    DateTime.now().month == selectedDate.month &&
                    DateTime.now().year == selectedDate.year;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Good Morning!' : 'Selected Day',
                      style: GoogleFonts.epilogue(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isToday ? 'Track your meals today' : _formatSelectedDate(selectedDate),
                      style: GoogleFonts.epilogue(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isToday ? Icons.today : Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          if (!isToday) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.textMedium,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Viewing meals for this day',
                    style: GoogleFonts.epilogue(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
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
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }

  Widget _buildCalorieCards(List<Meal> meals, CalendarProvider calendarProvider) {
    final totalCalories = meals.fold(0.0, (sum, meal) => sum + meal.calories);
    final targetCalories = 2000;
    final remainingCalories = targetCalories - totalCalories;
    final progressPercentage = (totalCalories / targetCalories).clamp(0.0, 1.0);

    // Calculate meal type breakdown
    final breakfastCalories = meals.where((m) => m.type == 'breakfast')
        .fold(0.0, (sum, meal) => sum + meal.calories);
    final lunchCalories = meals.where((m) => m.type == 'lunch')
        .fold(0.0, (sum, meal) => sum + meal.calories);
    final dinnerCalories = meals.where((m) => m.type == 'dinner')
        .fold(0.0, (sum, meal) => sum + meal.calories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Progress Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: totalCalories > targetCalories 
                ? [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)]
                : [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: totalCalories > targetCalories 
                ? Colors.red.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Daily Progress',
                      style: GoogleFonts.epilogue(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: totalCalories > targetCalories ? Colors.red : AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${(progressPercentage * 100).toInt()}%',
                      style: GoogleFonts.epilogue(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${totalCalories.toInt()}',
                          style: GoogleFonts.epilogue(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: totalCalories > targetCalories ? Colors.red : AppColors.primary,
                          ),
                        ),
                        Text(
                          'of ${targetCalories} calories',
                          style: GoogleFonts.epilogue(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.withOpacity(0.2)),
                        ),
                        CircularProgressIndicator(
                          value: progressPercentage,
                          strokeWidth: 6,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            totalCalories > targetCalories ? Colors.red : AppColors.primary,
                          ),
                        ),
                        Center(
                          child: Text(
                            '${remainingCalories.toInt()}',
                            style: GoogleFonts.epilogue(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Quick Stats
        Text(
          'Meal Breakdown',
          style: GoogleFonts.epilogue(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMealTypeCard(
              'Breakfast',
              breakfastCalories,
              CalendarProvider.mealCalorieLimits['breakfast']!,
              Icons.wb_sunny,
            ),
            const SizedBox(width: 12),
            _buildMealTypeCard(
              'Lunch',
              lunchCalories,
              CalendarProvider.mealCalorieLimits['lunch']!,
              Icons.lunch_dining,
            ),
            const SizedBox(width: 12),
            _buildMealTypeCard(
              'Dinner',
              dinnerCalories,
              CalendarProvider.mealCalorieLimits['dinner']!,
              Icons.dinner_dining,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealTypeCard(String mealType, double calories, double limit, IconData icon) {
    final isOverLimit = calories > limit;
    final percentage = (calories / limit).clamp(0.0, 1.0);
    
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverLimit ? Colors.red.withOpacity(0.3) : AppColors.lightGray,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isOverLimit ? Colors.red : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isOverLimit ? Colors.red : AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              mealType,
              style: GoogleFonts.epilogue(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              '${calories.toInt()}/${limit.toInt()}',
              style: GoogleFonts.epilogue(
                fontSize: 9,
                color: isOverLimit ? Colors.red : AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.5),
                color: Colors.grey.withOpacity(0.2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    color: isOverLimit ? Colors.red : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(CalendarProvider calendarProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.03),
            AppColors.primary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start Your Journey',
            textAlign: TextAlign.center,
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Track your nutrition, discover new recipes, and achieve your health goals with AI-powered insights',
              textAlign: TextAlign.center,
              style: GoogleFonts.epilogue(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-to-diary');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      'Add Meal',
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAISuggestions(calendarProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(
                      'AI Menu',
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickTip('🥗', 'Balanced'),
              _buildQuickTip('🤖', 'AI-Powered'),
              _buildQuickTip('📊', 'Tracked'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTip(String emoji, String text) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: GoogleFonts.epilogue(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  void _showAISuggestions(CalendarProvider calendarProvider) {
    calendarProvider.generateAISuggestions();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    "AI Menu Suggestions",
                    style: GoogleFonts.epilogue(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: calendarProvider.aiSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = calendarProvider.aiSuggestions[index];
                  return _buildAISuggestionCard(suggestion, calendarProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISuggestionCard(dynamic suggestion, CalendarProvider calendarProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  suggestion.title,
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${suggestion.healthScore}/10",
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.description,
            style: GoogleFonts.epilogue(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 12),
          // Show meal breakdown
          ...suggestion.meals.map((meal) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  _getMealIcon(meal.type),
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${meal.type.toUpperCase()}: ${meal.name}',
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Text(
                  '${meal.calories.toInt()} cal',
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 12),
          Text(
            "Total: ${suggestion.totalCalories.toInt()} calories",
            style: GoogleFonts.epilogue(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                calendarProvider.applyAISuggestion(suggestion, calendarProvider.selectedDay);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "AI suggestion applied successfully!",
                      style: GoogleFonts.epilogue(),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Apply Menu",
                style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildMealTimelineItem(Meal meal, bool isLast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Modern timeline indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.5),
                          AppColors.lightGray,
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Enhanced meal content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getMealIcon(meal.type),
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.type.toUpperCase(),
                                    style: GoogleFonts.epilogue(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                      letterSpacing: 0.6,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(meal.timestamp),
                                    style: GoogleFonts.epilogue(
                                      fontSize: 11,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${meal.calories.toInt()} cal',
                          style: GoogleFonts.epilogue(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    meal.name,
                    style: GoogleFonts.epilogue(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meal.description != null && meal.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      meal.description!,
                      style: GoogleFonts.epilogue(
                        fontSize: 13,
                        color: AppColors.textMedium,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (meal.ingredients != null && meal.ingredients!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: meal.ingredients!.take(3).map((ingredient) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ingredient,
                            style: GoogleFonts.epilogue(
                              fontSize: 10,
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                    if (meal.ingredients!.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${meal.ingredients!.length - 3} more',
                          style: GoogleFonts.epilogue(
                            fontSize: 10,
                            color: AppColors.textMedium,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          switch (index) {
            case 0:
              // Already on dashboard - do nothing
              break;
            case 1:
              // Navigate to calendar
              Navigator.pushNamed(context, '/calendar').then((_) {
                // Reset to home tab when returning
                setState(() {
                  _currentIndex = 0;
                });
              });
              break;
            case 2:
              // Show profile screen
              _showProfileScreen();
              break;
            case 3:
              // Back to onboarding
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/', 
                (route) => false,
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMedium,
        selectedLabelStyle: GoogleFonts.epilogue(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.epilogue(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_outlined),
            activeIcon: Icon(Icons.logout),
            label: 'Exit',
          ),
        ],
      ),
    );
  }

  void _showProfileScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: GoogleFonts.epilogue(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Health enthusiast',
                          style: GoogleFonts.epilogue(
                            fontSize: 14,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Profile options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Profile editing coming soon!',
                            style: GoogleFonts.epilogue(),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.track_changes,
                    title: 'Goals & Targets',
                    subtitle: 'Set your health and fitness goals',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Goals setting coming soon!',
                            style: GoogleFonts.epilogue(),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage your notification preferences',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Notification settings coming soon!',
                            style: GoogleFonts.epilogue(),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Help center coming soon!',
                            style: GoogleFonts.epilogue(),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'About Diyetgram',
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
                          ),
                          content: Text(
                            'Diyetgram v1.0.0\n\nYour personal nutrition companion powered by AI.\n\nDeveloped with ❤️ for healthy living.',
                            style: GoogleFonts.epilogue(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: GoogleFonts.epilogue(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Reset to home tab when profile closes
      setState(() {
        _currentIndex = 0;
      });
    });
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.epilogue(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.epilogue(
            fontSize: 13,
            color: AppColors.textMedium,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textMedium,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppColors.lightGray.withOpacity(0.3),
      ),
    );
  }
}