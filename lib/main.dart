import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/calendar_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_to_diary_screen.dart';
import 'screens/calendar_screen.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const DiyetgramApp());
}

class DiyetgramApp extends StatelessWidget {
  const DiyetgramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MealProvider()),
        ChangeNotifierProvider(create: (context) => CalendarProvider()),
      ],
      child: MaterialApp(
        title: 'Diyetgram',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: AppColors.primary,
          fontFamily: GoogleFonts.epilogue().fontFamily,
          scaffoldBackgroundColor: AppColors.background,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/add-to-diary': (context) => const AddToDiaryScreen(),
          '/calendar': (context) => const CalendarScreen(),
        },
      ),
    );
  }
} 