import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calendar_provider.dart';
import '../models/daily_meal_plan.dart';
import '../models/ai_menu_suggestion.dart';
import '../utils/app_colors.dart';
import '../main.dart'; // AuthService için

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarProvider>(context, listen: false).initializeSampleData();
    });
  }

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
          'Meal Planner',
          style: GoogleFonts.epilogue(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<CalendarProvider>(
          builder: (context, calendarProvider, child) {
            return Column(
              children: [
                _buildCalendar(calendarProvider),
                Expanded(
                  child: _buildSelectedDayContent(calendarProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendar(CalendarProvider provider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<DailyMealPlan>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: provider.focusedDay,
        calendarFormat: provider.calendarFormat,
        eventLoader: provider.getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: GoogleFonts.epilogue(color: AppColors.textMedium),
          holidayTextStyle: GoogleFonts.epilogue(color: AppColors.primary),
          defaultTextStyle: GoogleFonts.epilogue(color: AppColors.textDark),
          selectedTextStyle: GoogleFonts.epilogue(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          todayTextStyle: GoogleFonts.epilogue(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonTextStyle: GoogleFonts.epilogue(
            color: AppColors.primary,
            fontSize: 14,
          ),
          formatButtonDecoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          titleTextStyle: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        selectedDayPredicate: (day) {
          return isSameDay(provider.selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          provider.selectDay(selectedDay, focusedDay);
        },
        onFormatChanged: (format) {
          provider.setCalendarFormat(format);
        },
      ),
    );
  }

  Widget _buildSelectedDayContent(CalendarProvider provider) {
    final selectedPlan = provider.selectedDayPlan;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(provider),
          const SizedBox(height: 16),
          if (selectedPlan != null) ...[
            _buildCalorieProgress(selectedPlan),
            const SizedBox(height: 16),
            Expanded(child: _buildMealSections(selectedPlan, provider)),
          ] else ...[
            _buildEmptyDayContent(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildDayHeader(CalendarProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatSelectedDay(provider.selectedDay),
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        IconButton(
          onPressed: () => _showAddMealDialog(context, provider),
          icon: Icon(
            Icons.add_circle,
            color: AppColors.primary,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieProgress(DailyMealPlan plan) {
    final progress = plan.calorieProgress.clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daily Calories",
                style: GoogleFonts.epilogue(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                "${plan.totalCalories.toInt()} / ${plan.targetCalories.toInt()}",
                style: GoogleFonts.epilogue(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: plan.isOverTarget ? Colors.red : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              plan.isOverTarget ? Colors.red : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSections(DailyMealPlan plan, CalendarProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMealSection("Breakfast", plan.breakfast, provider),
          _buildMealSection("Lunch", plan.lunch, provider),
          _buildMealSection("Dinner", plan.dinner, provider),
          _buildMealSection("Snacks", plan.snacks, provider),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, List<dynamic> meals, CalendarProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(
                title,
                style: GoogleFonts.epilogue(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                "${meals.fold(0.0, (sum, meal) => sum + meal.calories).toInt()} cal",
                style: GoogleFonts.epilogue(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (meals.isEmpty)
            Text(
              "No meals added",
              style: GoogleFonts.epilogue(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            )
          else
            ...meals.map((meal) => _buildMealItem(meal, title.toLowerCase(), provider)),
        ],
      ),
    );
  }

  Widget _buildMealItem(dynamic meal, String mealType, CalendarProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: GoogleFonts.epilogue(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  "${meal.calories.toInt()} cal",
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              provider.removeMealFromPlan(provider.selectedDay, mealType, meal.id);
            },
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.red,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDayContent(CalendarProvider provider) {
    return Expanded(
      child: Column(
        children: [
          // Empty state message
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      "No meals planned",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.epilogue(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Start your healthy journey by adding meals or get AI-powered suggestions",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          color: AppColors.textMedium,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Action buttons - Fixed spacing
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddMealDialog(context, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: Text(
                      "Add Meal",
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAISuggestions(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      side: BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 20),
                    label: Text(
                      "AI Menu Suggestions",
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDay(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  void _showAddMealDialog(BuildContext context, CalendarProvider provider) {
    // Simplified meal addition - in a real app, this would navigate to the add meal screen
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Add Meal",
          style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: mealTypes.map((type) => 
            ListTile(
              title: Text(type, style: GoogleFonts.epilogue()),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add meal screen or show meal picker
                Navigator.pushNamed(context, '/add-to-diary');
              },
            ),
          ).toList(),
        ),
      ),
    );
  }

  void _showAISuggestions(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context, listen: false);
    
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
                itemCount: provider.aiSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = provider.aiSuggestions[index];
                  return _buildAISuggestionCard(suggestion, provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISuggestionCard(AIMenuSuggestion suggestion, CalendarProvider provider) {
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: suggestion.dietaryTags.map((tag) => 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ).toList(),
          ),
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
                provider.applyAISuggestion(suggestion, provider.selectedDay);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "AI suggestion applied to ${_formatSelectedDay(provider.selectedDay)}",
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
                "Apply to Selected Day",
                style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Logout",
          style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: GoogleFonts.epilogue(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.epilogue(color: AppColors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              // Use AuthService to logout
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              // AuthWrapper will automatically navigate to login screen
            },
            child: Text(
              "Logout",
              style: GoogleFonts.epilogue(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 