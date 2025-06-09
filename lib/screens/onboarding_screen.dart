import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              
              Text(
                'Diyetgram',
                style: GoogleFonts.epilogue(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 40),
              
              Text(
                'A minimalist approach to diet tracking',
                textAlign: TextAlign.center,
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Plan your meals, track calories, and achieve your health goals with smart AI suggestions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.epilogue(
                  fontSize: 16,
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
              ),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/dashboard');
                  },
                  child: Text(
                    'Start Your Journey',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Already have an account? Sign In',
                  style: GoogleFonts.epilogue(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
} 