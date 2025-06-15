import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderate';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _ageController = TextEditingController(text: widget.userProfile.age.toString());
    _weightController = TextEditingController(text: widget.userProfile.weight.toString());
    _heightController = TextEditingController(text: widget.userProfile.height.toString());
    _selectedGender = widget.userProfile.gender;
    _selectedActivityLevel = widget.userProfile.activityLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Profili Düzenle',
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
            onPressed: _isLoading ? null : _saveProfile,
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        _nameController.text.isNotEmpty 
                            ? _nameController.text[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.epilogue(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Personal Information Section
              _buildSectionTitle('Kişisel Bilgiler'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _nameController,
                label: 'Ad Soyad',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad soyad gerekli';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _emailController,
                label: 'E-posta',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta gerekli';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: 'Yaş',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Yaş gerekli';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 13 || age > 120) {
                          return 'Geçerli bir yaş girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedGender,
                      label: 'Cinsiyet',
                      icon: Icons.wc_outlined,
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Erkek')),
                        DropdownMenuItem(value: 'female', child: Text('Kadın')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Physical Information Section
              _buildSectionTitle('Fiziksel Bilgiler'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Kilo (kg)',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kilo gerekli';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 30 || weight > 300) {
                          return 'Geçerli bir kilo girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _heightController,
                      label: 'Boy (cm)',
                      icon: Icons.height_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Boy gerekli';
                        }
                        final height = double.tryParse(value);
                        if (height == null || height < 100 || height > 250) {
                          return 'Geçerli bir boy girin';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Activity Level Section
              _buildSectionTitle('Aktivite Seviyesi'),
              const SizedBox(height: 16),
              
              _buildDropdown(
                value: _selectedActivityLevel,
                label: 'Aktivite Seviyesi',
                icon: Icons.directions_run_outlined,
                items: const [
                  DropdownMenuItem(value: 'sedentary', child: Text('Hareketsiz (Ofis işi)')),
                  DropdownMenuItem(value: 'light', child: Text('Az Aktif (Hafif egzersiz)')),
                  DropdownMenuItem(value: 'moderate', child: Text('Orta Aktif (Düzenli egzersiz)')),
                  DropdownMenuItem(value: 'active', child: Text('Çok Aktif (Yoğun egzersiz)')),
                  DropdownMenuItem(value: 'very_active', child: Text('Aşırı Aktif (Çok yoğun egzersiz)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedActivityLevel = value!;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Current Stats
              if (_weightController.text.isNotEmpty && _heightController.text.isNotEmpty)
                Container(
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
                      Text(
                        'Mevcut İstatistikler',
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('BMI', _calculateBMI()),
                          _buildStatItem('BMR', '${_calculateBMR().round()} kal'),
                          _buildStatItem('TDEE', '${_calculateTDEE().round()} kal'),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.epilogue(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.epilogue(
          fontSize: 16,
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.epilogue(
            color: AppColors.textMedium,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 2,
            ),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: GoogleFonts.epilogue(
          fontSize: 16,
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.epilogue(
            color: AppColors.textMedium,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.epilogue(
            fontSize: 12,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  String _calculateBMI() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    if (weight > 0 && height > 0) {
      final bmi = weight / ((height / 100) * (height / 100));
      return bmi.toStringAsFixed(1);
    }
    return '0.0';
  }

  double _calculateBMR() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final age = int.tryParse(_ageController.text) ?? 0;
    
    if (weight > 0 && height > 0 && age > 0) {
      if (_selectedGender == 'male') {
        return 10 * weight + 6.25 * height - 5 * age + 5;
      } else {
        return 10 * weight + 6.25 * height - 5 * age - 161;
      }
    }
    return 0;
  }

  double _calculateTDEE() {
    final bmr = _calculateBMR();
    double multiplier;
    switch (_selectedActivityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'light':
        multiplier = 1.375;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'active':
        multiplier = 1.725;
        break;
      case 'very_active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.2;
    }
    return bmr * multiplier;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save to SharedPreferences
      await prefs.setString('user_name', _nameController.text);
      await prefs.setString('user_email', _emailController.text);
      await prefs.setInt('user_age', int.parse(_ageController.text));
      await prefs.setDouble('user_weight', double.parse(_weightController.text));
      await prefs.setDouble('user_height', double.parse(_heightController.text));
      await prefs.setString('user_gender', _selectedGender);
      await prefs.setString('user_activity_level', _selectedActivityLevel);
      
      // Calculate and save daily calorie goal
      final tdee = _calculateTDEE();
      await prefs.setInt('user_daily_calorie_goal', tdee.round());

      // Create updated user profile
      final updatedProfile = widget.userProfile.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
        dailyCalorieGoal: tdee.round(),
        updatedAt: DateTime.now(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profil başarıyla güncellendi!',
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
            'Profil güncellenirken hata oluştu: $e',
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