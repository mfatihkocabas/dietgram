import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/ai_nutrition_service.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';

class AddCustomMealScreen extends StatefulWidget {
  final String mealType;
  final DateTime selectedDate;

  const AddCustomMealScreen({
    super.key,
    required this.mealType,
    required this.selectedDate,
  });

  @override
  State<AddCustomMealScreen> createState() => _AddCustomMealScreenState();
}

class _AddCustomMealScreenState extends State<AddCustomMealScreen> {
  final _mealNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isAnalyzing = false;
  NutritionEstimate? _nutritionEstimate;
  final AINutritionService _aiService = AINutritionService();

  @override
  void dispose() {
    _mealNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _analyzeFood() async {
    if (_descriptionController.text.trim().isEmpty) {
      _showSnackBar('Lütfen yemek açıklaması girin', isError: true);
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _nutritionEstimate = null;
    });

    try {
      final estimate = await _aiService.analyzeFood(_descriptionController.text.trim());
      setState(() {
        _nutritionEstimate = estimate;
        if (_mealNameController.text.isEmpty && estimate != null) {
          _mealNameController.text = estimate.recognizedFood;
        }
      });
      _showSnackBar('AI analizi tamamlandı!', isError: false);
    } catch (e) {
      _showSnackBar('Analiz sırasında hata oluştu', isError: true);
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _addMeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nutritionEstimate == null) {
      _showSnackBar('Önce AI analizi yapın', isError: true);
      return;
    }

    // Kalori sınırı kontrolü
    if (_aiService.checkMealCalorieLimit(widget.mealType, _nutritionEstimate!.nutrition.calories)) {
      _showCalorieWarningDialog();
      return;
    }

    await _saveMeal();
  }

  Future<void> _saveMeal() async {
    final meal = Meal(
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
      await Provider.of<MealProvider>(context, listen: false).addMeal(meal);
      _showSnackBar('Öğün başarıyla eklendi!', isError: false);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Öğün eklenirken hata oluştu', isError: true);
    }
  }

  void _showCalorieWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kalori Sınırı Uyarısı', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        content: Text('Bu öğün ${_getMealTypeName(widget.mealType)} için önerilen kalori sınırını aşıyor.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveMeal();
            },
            child: const Text('Yine de Ekle'),
          ),
        ],
      ),
    );
  }

  String _getMealTypeName(String mealType) {
    switch (mealType) {
      case 'breakfast': return 'Kahvaltı';
      case 'lunch': return 'Öğle Yemeği';
      case 'dinner': return 'Akşam Yemeği';
      case 'snack': return 'Atıştırmalık';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Kendi Öğününü Ekle', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Öğün tipi
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
                    Text(_getMealTypeName(widget.mealType), 
                         style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Yemek açıklaması
              Text('Yemek Açıklaması', style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Örnek: Domates biber ile menemen yaptım, 2 yumurta kullandım...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Açıklama gereklidir' : null,
              ),
              
              const SizedBox(height: 16),
              
              // AI Analiz butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeFood,
                  icon: _isAnalyzing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.psychology),
                  label: Text(_isAnalyzing ? 'AI Analiz Ediliyor...' : 'AI ile Analiz Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              if (_nutritionEstimate != null) ...[
                const SizedBox(height: 24),
                
                // Analiz sonuçları
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('AI Analiz Sonucu', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(_nutritionEstimate!.recognizedFood, 
                           style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      
                      // Kalori vurgusu
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
                            Text('${_nutritionEstimate!.nutrition.calories.round()} Kalori',
                                 style: GoogleFonts.epilogue(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Öğün adı
                Text('Öğün Adı', style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mealNameController,
                  decoration: InputDecoration(
                    hintText: 'Öğün için bir isim verin',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Öğün adı gereklidir' : null,
                ),
                
                const SizedBox(height: 24),
                
                // Ekle butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addMeal,
                    icon: const Icon(Icons.add),
                    label: const Text('Öğünü Günlüğe Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 