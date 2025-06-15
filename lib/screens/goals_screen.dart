import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../models/user_profile.dart';

class GoalsScreen extends StatefulWidget {
  final UserProfile userProfile;

  const GoalsScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String _selectedGoal = 'maintain_weight';
  double _targetWeight = 0;
  int _targetCalories = 2000;
  int _targetWaterGlasses = 8;
  int _targetSteps = 10000;
  int _targetWorkouts = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentGoals();
  }

  Future<void> _loadCurrentGoals() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _selectedGoal = widget.userProfile.goal;
      _targetWeight = prefs.getDouble('target_weight') ?? widget.userProfile.weight;
      _targetCalories = prefs.getInt('target_calories') ?? widget.userProfile.dailyCalorieGoal;
      _targetWaterGlasses = prefs.getInt('target_water_glasses') ?? 8;
      _targetSteps = prefs.getInt('target_steps') ?? 10000;
      _targetWorkouts = prefs.getInt('target_workouts') ?? 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Hedefler ve Amaçlar',
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveGoals,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(
                    'Kaydet',
                    style: GoogleFonts.epilogue(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Goal Section
            _buildSectionCard(
              title: 'Ana Hedef',
              icon: Icons.flag_outlined,
              child: Column(
                children: [
                  _buildGoalOption(
                    title: 'Kilo Ver',
                    subtitle: 'Sağlıklı bir şekilde kilo kaybetmek istiyorum',
                    value: 'lose_weight',
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildGoalOption(
                    title: 'Kilonu Koru',
                    subtitle: 'Mevcut kilomu korumak istiyorum',
                    value: 'maintain_weight',
                    icon: Icons.balance,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildGoalOption(
                    title: 'Kilo Al',
                    subtitle: 'Sağlıklı bir şekilde kilo almak istiyorum',
                    value: 'gain_weight',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Target Weight Section
            _buildSectionCard(
              title: 'Hedef Kilo',
              icon: Icons.monitor_weight_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mevcut Kilo: ${widget.userProfile.weight.toStringAsFixed(1)} kg',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _targetWeight,
                          min: 40,
                          max: 150,
                          divisions: 110,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.primary.withOpacity(0.2),
                          onChanged: (value) {
                            setState(() {
                              _targetWeight = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_targetWeight.toStringAsFixed(1)} kg',
                          style: GoogleFonts.epilogue(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Daily Targets Section
            _buildSectionCard(
              title: 'Günlük Hedefler',
              icon: Icons.today_outlined,
              child: Column(
                children: [
                  _buildTargetSlider(
                    title: 'Kalori Hedefi',
                    value: _targetCalories.toDouble(),
                    min: 1200,
                    max: 4000,
                    divisions: 280,
                    unit: 'kal',
                    onChanged: (value) {
                      setState(() {
                        _targetCalories = value.round();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTargetSlider(
                    title: 'Su İçme Hedefi',
                    value: _targetWaterGlasses.toDouble(),
                    min: 4,
                    max: 15,
                    divisions: 11,
                    unit: 'bardak',
                    onChanged: (value) {
                      setState(() {
                        _targetWaterGlasses = value.round();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTargetSlider(
                    title: 'Adım Hedefi',
                    value: _targetSteps.toDouble(),
                    min: 5000,
                    max: 20000,
                    divisions: 30,
                    unit: 'adım',
                    onChanged: (value) {
                      setState(() {
                        _targetSteps = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Weekly Targets Section
            _buildSectionCard(
              title: 'Haftalık Hedefler',
              icon: Icons.calendar_view_week_outlined,
              child: _buildTargetSlider(
                title: 'Egzersiz Hedefi',
                value: _targetWorkouts.toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                unit: 'gün',
                onChanged: (value) {
                  setState(() {
                    _targetWorkouts = value.round();
                  });
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Progress Prediction
            if (_selectedGoal != 'maintain_weight')
              _buildSectionCard(
                title: 'Tahmini İlerleme',
                icon: Icons.timeline_outlined,
                child: _buildProgressPrediction(),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildGoalOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedGoal == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.epilogue(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required void Function(double) onChanged,
  }) {
    return Column(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.round()} $unit',
                style: GoogleFonts.epilogue(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildProgressPrediction() {
    final currentWeight = widget.userProfile.weight;
    final weightDifference = (_targetWeight - currentWeight).abs();
    final weeksToGoal = (weightDifference / 0.5).ceil(); // Assuming 0.5kg per week
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _selectedGoal == 'lose_weight' ? Icons.trending_down : Icons.trending_up,
              color: _selectedGoal == 'lose_weight' ? Colors.red : Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _selectedGoal == 'lose_weight' 
                  ? '${weightDifference.toStringAsFixed(1)} kg kaybetmek'
                  : '${weightDifference.toStringAsFixed(1)} kg almak',
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tahmini Süre:',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                  Text(
                    '$weeksToGoal hafta',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Haftalık Hedef:',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                  Text(
                    '0.5 kg',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '* Bu tahmin sağlıklı kilo verme/alma hızına dayanmaktadır. Gerçek sonuçlar kişiden kişiye değişebilir.',
          style: GoogleFonts.epilogue(
            fontSize: 12,
            color: AppColors.textMedium,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Future<void> _saveGoals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save goals to SharedPreferences
      await prefs.setString('user_goal', _selectedGoal);
      await prefs.setDouble('target_weight', _targetWeight);
      await prefs.setInt('target_calories', _targetCalories);
      await prefs.setInt('target_water_glasses', _targetWaterGlasses);
      await prefs.setInt('target_steps', _targetSteps);
      await prefs.setInt('target_workouts', _targetWorkouts);
      await prefs.setInt('user_daily_calorie_goal', _targetCalories);

      // Create updated user profile
      final updatedProfile = widget.userProfile.copyWith(
        goal: _selectedGoal,
        dailyCalorieGoal: _targetCalories,
        updatedAt: DateTime.now(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hedefleriniz başarıyla kaydedildi!',
            style: GoogleFonts.epilogue(),
          ),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context, updatedProfile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hedefler kaydedilirken hata oluştu: $e',
            style: GoogleFonts.epilogue(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 