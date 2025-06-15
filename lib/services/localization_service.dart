import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _cachePrefix = 'localization_cache_';
  static const Duration _cacheExpiry = Duration(hours: 6);
  
  Locale _currentLocale = const Locale('tr');
  Map<String, Map<String, String>> _localizations = {};
  bool _isLoading = false;
  
  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;
  
  // Initialize the service
  Future<void> initialize() async {
    await _loadSavedLanguage();
    
    // Immediately set default localizations
    _localizations['en'] = _getDefaultEnglishLocalizations();
    _localizations['tr'] = _getDefaultTurkishLocalizations();
    
    notifyListeners();
    
    // Then try to load from cache in background
    await _loadLocalizations();
  }
  
  // Load saved language preference
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'tr';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }
  
  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;
    
    _currentLocale = Locale(languageCode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    await _loadLocalizations();
    notifyListeners();
  }
  
  // Load localizations (using default values for now, can be extended with remote config later)
  Future<void> _loadLocalizations() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // For now, just use default localizations
      // In the future, we can add Firebase Remote Config here
      await _loadFromCache();
    } catch (e) {
      print('Error loading localizations: $e');
      _localizations['en'] = _getDefaultEnglishLocalizations();
      _localizations['tr'] = _getDefaultTurkishLocalizations();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Load from local cache or use defaults
  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check cache expiry
    final cacheTimestamp = prefs.getInt('${_cachePrefix}timestamp') ?? 0;
    final cacheExpired = DateTime.now().millisecondsSinceEpoch - cacheTimestamp > _cacheExpiry.inMilliseconds;
    
    if (!cacheExpired) {
      final enCache = prefs.getString('${_cachePrefix}en');
      final trCache = prefs.getString('${_cachePrefix}tr');
      
      if (enCache != null && trCache != null) {
        _localizations['en'] = Map<String, String>.from(json.decode(enCache));
        _localizations['tr'] = Map<String, String>.from(json.decode(trCache));
        return;
      }
    }
    
    // If cache is expired or doesn't exist, use default values
    _localizations['en'] = _getDefaultEnglishLocalizations();
    _localizations['tr'] = _getDefaultTurkishLocalizations();
    
    // Cache the default values
    await _cacheLocalizations();
  }
  
  // Cache localizations
  Future<void> _cacheLocalizations() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('${_cachePrefix}en', json.encode(_localizations['en']));
    await prefs.setString('${_cachePrefix}tr', json.encode(_localizations['tr']));
    await prefs.setInt('${_cachePrefix}timestamp', DateTime.now().millisecondsSinceEpoch);
  }
  
  // Get localized string
  String getString(String key) {
    final languageCode = _currentLocale.languageCode;
    
    // If localizations not loaded yet, load defaults immediately
    if (_localizations.isEmpty) {
      _localizations['en'] = _getDefaultEnglishLocalizations();
      _localizations['tr'] = _getDefaultTurkishLocalizations();
    }
    
    final localizedString = _localizations[languageCode]?[key];
    
    // Try fallback to English if key not found in current language
    if (localizedString == null) {
      final fallback = _localizations['en']?[key];
      return fallback ?? key;
    }
    
    return localizedString;
  }
  
  // Get localized string with parameters
  String getStringWithParams(String key, Map<String, dynamic> params) {
    String text = getString(key);
    
    params.forEach((paramKey, value) {
      text = text.replaceAll('{$paramKey}', value.toString());
    });
    
    return text;
  }
  
  // Default English localizations
  Map<String, String> _getDefaultEnglishLocalizations() {
    return {
      'appName': 'Dietgram',
      'appTitle': 'Dietgram - Diet Tracker',
      'onboardingWelcome': 'Welcome to Dietgram',
      'onboardingSubtitle': 'Your AI-powered nutrition companion for a healthier lifestyle',
      'onboardingGetStarted': 'Get Started',
      'onboardingSkip': 'Skip',
      'loginTitle': 'Sign In',
      'loginWelcome': 'Welcome Back!',
      'loginSubtitle': 'Continue your healthy journey',
      'loginEmail': 'Email',
      'loginEmailHint': 'example@domain.com',
      'loginPassword': 'Password',
      'loginPasswordHint': '••••••••',
      'loginSignIn': 'Sign In',
      'loginSignUp': 'Sign Up',
      'loginForgotPassword': 'Forgot Password?',
      'loginNoAccount': "Don't have an account?",
      'loginHaveAccount': 'Already have an account?',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
      'signUpLink': 'Sign Up',
      'signInLink': 'Sign In',
      'signUpTitle': 'Create Account',
      'signUpSubtitle': 'Join thousands on their wellness journey',
      'signUpButton': 'Create Account',
      'emailRequired': 'Email is required',
      'emailInvalid': 'Please enter a valid email',
      'passwordRequired': 'Password is required',
      'passwordTooShort': 'Password must be at least 6 characters',
      'loginOr': 'or',
      'loginContinueAsGuest': 'Continue as guest',
      'loginGuestSubtitle': 'Experience the app without creating an account',
      'resetPasswordTitle': 'Reset Password',
      'resetPasswordDescription': 'Enter your email address and we\'ll send you a link to reset your password.',
      'resetPasswordSuccess': 'Password reset email sent! Check your inbox.',
      'cancel': 'Cancel',
      'sendResetEmail': 'Send Reset Email',
      'dashboardGoodMorning': 'Good Morning!',
      'dashboardTrackMeals': 'Track your meals today',
      'dashboardSelectedDay': 'Selected Day',
      'dashboardViewingDay': 'Viewing meals for this day',
      'dashboardDailyProgress': 'Daily Progress',
      'dashboardMealBreakdown': 'Meal Breakdown',
      'dashboardTimeline': 'Timeline',
      'dashboardViewCalendar': 'View Calendar',
      'dashboardStartJourney': 'Start Your Journey',
      'dashboardTrackNutrition': 'Track your nutrition, discover new recipes, and achieve your health goals with AI-powered insights',
      'dashboardAddMeal': 'Add Meal',
      'dashboardAIMenu': 'AI Menu',
      'mealBreakfast': 'Breakfast',
      'mealLunch': 'Lunch',
      'mealDinner': 'Dinner',
      'mealSnack': 'Snack',
      'mealTypeBreakfast': 'Breakfast',
      'mealTypeLunch': 'Lunch',
      'mealTypeDinner': 'Dinner',
      'mealTypeSnack': 'Snack',
      'addToDiaryTitle': 'Add to Diary',
      'addToDiarySelectMealType': 'Select Meal Type',
      'addToDiaryChooseMeal': 'Choose meal for {date}',
      'addToDiaryBreakfastTime': '6:00 - 10:00 AM',
      'addToDiaryLunchTime': '12:00 - 2:00 PM', 
      'addToDiaryDinnerTime': '6:00 - 9:00 PM',
      'addToDiarySnackTime': 'Anytime',
      'addToDiary': 'Add to Diary',
      'selectMealType': 'Select meal type',
      'profileEditProfile': 'Edit Profile',
      'profileGoalsTargets': 'Goals & Targets',
      'profileNotifications': 'Notifications',
      'profileHelp': 'Help & Support',
      'profileAbout': 'About',
      'navigationHome': 'Home',
      'navigationCalendar': 'Calendar',
      'navigationProfile': 'Profile',
      'navigationExit': 'Exit',
      'dateToday': 'Today',
      'dateTomorrow': 'Tomorrow',
      'dateYesterday': 'Yesterday',
      'errorNetwork': 'Network error. Please check your connection.',
      'errorGeneral': 'Something went wrong. Please try again.',
      'loadingPleaseWait': 'Please wait...',
      'settingsLanguage': 'Language',
      'settingsEnglish': 'English',
      'settingsTurkish': 'Turkish',
      'dashboardCalories': 'calories',
      'dashboardOf': 'of',
      'dashboardNoMealsPlanned': 'No meals planned',
      'dashboardNoMealsDescription': 'Start your healthy journey by adding meals or get AI-powered suggestions',
      'dashboardGetAISuggestions': 'Get AI Suggestions',
      'dashboardEmptyStateTitle': 'Start Your Journey',
      'dashboardEmptyStateDescription': 'Track your nutrition, discover new recipes, and achieve your health goals with AI-powered insights',
      'dashboardPremiumFeatures': 'Premium Features',
      'dashboardPremiumDescription': 'Unlock advanced features and personalized insights',
      'dashboardUpgrade': 'Upgrade',
      'dashboardWeeks': 'weeks',
      'aiMenuSuggestions': 'AI Menu Suggestions',
      'totalCalories': 'Total',
      'applyMenu': 'Apply Menu',
      'aiSuggestionApplied': 'AI suggestion applied successfully!',
      
      // Add to Diary Screen
      'addToDiaryTitle': 'Add to Diary',
      'addToDiarySelectMealType': 'Select meal type',
      'addToDiaryChooseMeal': 'Choose which meal to add to {date}',
      'addToDiaryBreakfastTime': '6-10 AM',
      'addToDiaryLunchTime': '12-3 PM',
      'addToDiaryDinnerTime': '6-9 PM',
      'addToDiarySnackTime': 'Anytime',
      'addToDiaryOptionsTitle': '{mealType} Options',
      'addToDiaryAddToDate': 'Add to {date}',
      'addToDiaryCalorieLimit': 'Calorie Limit Warning',
      'addToDiaryCalorieLimitMessage': 'Adding this meal will exceed the recommended calorie limit for {mealType}.',
      'addToDiaryCurrent': 'Current: {calories} cal',
      'addToDiaryAdding': 'Adding: {calories} cal',
      'addToDiaryTotal': 'Total: {calories} cal',
      'addToDiaryLimit': 'Limit: {calories} cal',
      'addToDiaryAddAnyway': 'Add Anyway',
      'addToDiaryMealAdded': '{meal} added to {date}',
      'addToDiaryAddCustomMeal': 'Add Your Own Meal',
      'addToDiaryDailyLimitExceeded': 'Daily Limit Exceeded',
      'addToDiaryDailyLimitMessage': 'Free users can add {limit} custom meals per day.',
      'addToDiaryDailyLimitUsage': 'Today you have added {used}/{limit} custom meals.',
      'addToDiaryUpgradePremium': 'Upgrade to Premium to add unlimited custom meals!',
      'addToDiaryUpgradeButton': 'Upgrade to Premium',
      'addToDiaryAILimitTitle': 'AI Analysis Limit',
      'addToDiaryAILimitMessage': 'Free users can perform {limit} AI analyses per week.',
      'addToDiaryAILimitUsage': 'This week you have performed {used}/{limit} analyses.',
      'addToDiaryAILimitUpgrade': 'Upgrade to Premium for unlimited AI analysis!',
      'addToDiaryFoodDescription': 'Food Description',
      'addToDiaryFoodDescriptionHint': 'Example: I made menemen with tomatoes and peppers, used 2 eggs...',
      'addToDiaryDescriptionRequired': 'Description is required',
      'addToDiaryAnalyzeWithAI': 'Analyze with AI',
      'addToDiaryAnalyzing': 'AI Analyzing...',
      'addToDiaryAIResult': 'AI Analysis Result',
      'addToDiaryCalories': '{calories} Calories',
      'addToDiaryMealName': 'Meal Name',
      'addToDiaryMealNameHint': 'Give a name to your meal',
      'addToDiaryMealNameRequired': 'Meal name is required',
      'addToDiaryAddToJournal': 'Add to Journal',
      'addToDiaryEnterFoodDescription': 'Please enter a food description',
      'addToDiaryAIAnalysisComplete': 'AI analysis completed successfully',
      'addToDiaryAnalysisError': 'Analysis failed, please try again',
      'addToDiaryAnalysisRequired': 'Please analyze the food first',
      'addToDiaryMealAddedSuccessfully': 'Meal added successfully',
      'addToDiaryMealAddError': 'Failed to add meal',
      'addToDiaryCalorieWarning': 'Calorie Limit Warning',
      'addToDiaryCalorieWarningMessage': 'This meal exceeds the recommended calorie limit for {mealType}.',
      'addToDiaryAddAnyway': 'Add Anyway',
      
      // Meal Options
      'mealOatmealBerries': 'Oatmeal with Berries',
      'mealOatmealBerriesDesc': 'Rolled oats with mixed berries and honey',
      'mealGreekYogurt': 'Greek Yogurt Parfait',
      'mealGreekYogurtDesc': 'Greek yogurt layered with granola and fruit',
      'mealAvocadoToast': 'Avocado Toast',
      'mealAvocadoToastDesc': 'Whole grain toast with smashed avocado',
      'mealScrambledEggs': 'Scrambled Eggs',
      'mealScrambledEggsDesc': 'Two eggs scrambled with herbs',
      'mealGrilledChickenSalad': 'Grilled Chicken Salad',
      'mealGrilledChickenSaladDesc': 'Mixed greens with grilled chicken breast',
      'mealQuinoaBowl': 'Quinoa Bowl',
      'mealQuinoaBowlDesc': 'Quinoa with roasted vegetables and tahini',
      'mealTurkeySandwich': 'Turkey Sandwich',
      'mealTurkeySandwichDesc': 'Whole grain sandwich with turkey and vegetables',
      'mealLentilSoup': 'Lentil Soup',
      'mealLentilSoupDesc': 'Hearty lentil soup with vegetables',
      'mealGrilledSalmon': 'Grilled Salmon',
      'mealGrilledSalmonDesc': 'Grilled salmon with roasted vegetables',
      'mealChickenStirFry': 'Chicken Stir Fry',
      'mealChickenStirFryDesc': 'Chicken with mixed vegetables in light sauce',
      'mealVegetableCurry': 'Vegetable Curry',
      'mealVegetableCurryDesc': 'Mixed vegetables in coconut curry sauce',
      'mealPastaPrimavera': 'Pasta Primavera',
      'mealPastaPrimaveraDesc': 'Whole grain pasta with seasonal vegetables',
      'mealMixedNuts': 'Mixed Nuts',
      'mealMixedNutsDesc': 'A handful of mixed nuts',
      'mealApplePeanutButter': 'Apple with Peanut Butter',
      'mealApplePeanutButterDesc': 'Sliced apple with natural peanut butter',
      'mealProteinSmoothie': 'Protein Smoothie',
      'mealProteinSmoothieDesc': 'Protein smoothie with fruits',
      'mealHummusVegetables': 'Hummus with Vegetables',
      'mealHummusVegetablesDesc': 'Fresh vegetables with hummus dip',
      
      // Additional strings that might be referenced
      'enterFoodDescription': 'Please enter a food description',
      'aiAnalysisComplete': 'AI analysis completed successfully',
      'analysisError': 'Analysis failed, please try again',
      'analysisRequired': 'Please analyze the food first',
      'mealAddedSuccessfully': 'Meal added successfully',
      'mealAddError': 'Failed to add meal',
    };
  }
  
  // Default Turkish localizations
  Map<String, String> _getDefaultTurkishLocalizations() {
    return {
      'appName': 'Diyetgram',
      'appTitle': 'Diyetgram - Diyet Takipçisi',
      'onboardingWelcome': "Diyetgram'a Hoş Geldiniz",
      'onboardingSubtitle': 'Daha sağlıklı bir yaşam tarzı için AI destekli beslenme yardımcınız',
      'onboardingGetStarted': 'Başlayalım',
      'onboardingSkip': 'Geç',
      'loginTitle': 'Giriş Yap',
      'loginWelcome': 'Tekrar Hoş Geldiniz!',
      'loginSubtitle': 'Sağlıklı yolculuğunuza devam etmek için giriş yapın',
      'loginEmail': 'E-posta Adresi',
      'loginEmailHint': 'ornek@domain.com',
      'loginPassword': 'Şifre',
      'loginPasswordHint': '••••••••',
      'loginSignIn': 'Giriş Yap',
      'loginSignUp': 'Kayıt Ol',
      'loginForgotPassword': 'Şifremi Unuttum?',
      'loginNoAccount': 'Hesabınız yok mu?',
      'loginHaveAccount': 'Zaten bir hesabınız var mı?',
      'forgotPassword': 'Şifremi Unuttum?',
      'dontHaveAccount': 'Hesabınız yok mu?',
      'alreadyHaveAccount': 'Zaten bir hesabınız var mı?',
      'signUpLink': 'Kayıt Ol',
      'signInLink': 'Giriş Yap',
      'signUpTitle': 'Hesap Oluştur',
      'signUpSubtitle': 'Sağlık yolculuğundaki binlerce kişiye katılın',
      'signUpButton': 'Hesap Oluştur',
      'emailRequired': 'E-posta gereklidir',
      'emailInvalid': 'Geçerli bir e-posta adresi girin',
      'passwordRequired': 'Şifre gereklidir',
      'passwordTooShort': 'Şifre en az 6 karakter olmalıdır',
      'loginOr': 'veya',
      'loginContinueAsGuest': 'Misafir olarak devam et',
      'loginGuestSubtitle': 'Hesap oluşturmadan uygulamayı deneyin',
      'resetPasswordTitle': 'Şifre Sıfırlama',
      'resetPasswordDescription': 'E-posta adresinizi girin, şifrenizi sıfırlamak için size bir bağlantı gönderelim.',
      'resetPasswordSuccess': 'Şifre sıfırlama e-postası gönderildi! Gelen kutunuzu kontrol edin.',
      'cancel': 'İptal',
      'sendResetEmail': 'Sıfırlama E-postası Gönder',
      'dashboardGoodMorning': 'Günaydın!',
      'dashboardTrackMeals': 'Bugün öğünlerinizi takip edin',
      'dashboardSelectedDay': 'Seçili Gün',
      'dashboardViewingDay': 'Bu gün için öğünleri görüntülüyorsunuz',
      'dashboardDailyProgress': 'Günlük İlerleme',
      'dashboardMealBreakdown': 'Öğün Dağılımı',
      'dashboardTimeline': 'Zaman Çizelgesi',
      'dashboardViewCalendar': 'Takvimi Görüntüle',
      'dashboardStartJourney': 'Yolculuğunuza Başlayın',
      'dashboardTrackNutrition': 'Beslenmenizi takip edin, yeni tarifler keşfedin ve AI destekli içgörülerle sağlık hedeflerinize ulaşın',
      'dashboardAddMeal': 'Öğün Ekle',
      'dashboardAIMenu': 'AI Menü',
      'mealBreakfast': 'Kahvaltı',
      'mealLunch': 'Öğle Yemeği',
      'mealDinner': 'Akşam Yemeği',
      'mealSnack': 'Atıştırmalık',
      'mealTypeBreakfast': 'Kahvaltı',
      'mealTypeLunch': 'Öğle Yemeği',
      'mealTypeDinner': 'Akşam Yemeği',
      'mealTypeSnack': 'Atıştırmalık',
      'addToDiaryTitle': 'Günlüğe Ekle',
      'addToDiarySelectMealType': 'Öğün Türü Seç',
      'addToDiaryChooseMeal': '{date} için yemek seç',
      'addToDiaryBreakfastTime': '06:00 - 10:00',
      'addToDiaryLunchTime': '12:00 - 14:00', 
      'addToDiaryDinnerTime': '18:00 - 21:00',
      'addToDiarySnackTime': 'Her zaman',
      'addToDiary': 'Günlüğe Ekle',
      'selectMealType': 'Öğün türünü seçin',
      'profileEditProfile': 'Profili Düzenle',
      'profileGoalsTargets': 'Hedefler ve Amaçlar',
      'profileNotifications': 'Bildirimler',
      'profileHelp': 'Yardım ve Destek',
      'profileAbout': 'Hakkında',
      'navigationHome': 'Ana Sayfa',
      'navigationCalendar': 'Takvim',
      'navigationProfile': 'Profil',
      'navigationExit': 'Çıkış',
      'dateToday': 'Bugün',
      'dateTomorrow': 'Yarın',
      'dateYesterday': 'Dün',
      'errorNetwork': 'Ağ hatası. Lütfen bağlantınızı kontrol edin.',
      'errorGeneral': 'Bir şeyler ters gitti. Lütfen tekrar deneyin.',
      'loadingPleaseWait': 'Lütfen bekleyin...',
      'settingsLanguage': 'Dil',
      'settingsEnglish': 'İngilizce',
      'settingsTurkish': 'Türkçe',
      'dashboardCalories': 'kalori',
      'dashboardOf': '/',
      'dashboardNoMealsPlanned': 'Öğün planlanmamış',
      'dashboardNoMealsDescription': 'Öğün ekleyerek veya AI destekli öneriler alarak sağlıklı yolculuğunuza başlayın',
      'dashboardGetAISuggestions': 'AI Önerileri Al',
      'dashboardEmptyStateTitle': 'Yolculuğunuza Başlayın',
      'dashboardEmptyStateDescription': 'Beslenmenizi takip edin, yeni tarifler keşfedin ve AI destekli içgörülerle sağlık hedeflerinize ulaşın',
      'dashboardPremiumFeatures': 'Premium Özellikler',
      'dashboardPremiumDescription': 'Gelişmiş özelliklerin ve kişiselleştirilmiş içgörülerin kilidini açın',
      'dashboardUpgrade': 'Yükselt',
      'dashboardWeeks': 'hafta',
      'aiMenuSuggestions': 'AI Menü Önerileri',
      'totalCalories': 'Toplam',
      'applyMenu': 'Menüyü Uygula',
      'aiSuggestionApplied': 'AI önerisi başarıyla uygulandı!',
      
      // Add to Diary Screen
      'addToDiaryTitle': 'Günlüğe Ekle',
      'addToDiarySelectMealType': 'Öğün türünü seçin',
      'addToDiaryChooseMeal': '{date} tarihine hangi öğünü eklemek istiyorsunuz',
      'addToDiaryBreakfastTime': '06:00-10:00',
      'addToDiaryLunchTime': '12:00-15:00',
      'addToDiaryDinnerTime': '18:00-21:00',
      'addToDiarySnackTime': 'Her zaman',
      'addToDiaryOptionsTitle': '{mealType} Seçenekleri',
      'addToDiaryAddToDate': '{date} tarihine ekle',
      'addToDiaryCalorieLimit': 'Kalori Sınırı Uyarısı',
      'addToDiaryCalorieLimitMessage': 'Bu öğünü eklemek {mealType} için önerilen kalori sınırını aşacak.',
      'addToDiaryCurrent': 'Mevcut: {calories} kal',
      'addToDiaryAdding': 'Eklenen: {calories} kal',
      'addToDiaryTotal': 'Toplam: {calories} kal',
      'addToDiaryLimit': 'Sınır: {calories} kal',
      'addToDiaryAddAnyway': 'Yine de Ekle',
      'addToDiaryMealAdded': '{meal} {date} tarihine eklendi',
      'addToDiaryAddCustomMeal': 'Kendi Öğününü Ekle',
      'addToDiaryDailyLimitExceeded': 'Günlük Limit Aşıldı',
      'addToDiaryDailyLimitMessage': 'Ücretsiz kullanıcılar günde {limit} özel yemek ekleyebilir.',
      'addToDiaryDailyLimitUsage': 'Bugün {used}/{limit} özel yemek eklediniz.',
      'addToDiaryUpgradePremium': 'Premium\'a geçerek sınırsız özel yemek ekleyebilirsiniz!',
      'addToDiaryUpgradeButton': 'Premium\'a Geç',
      'addToDiaryAILimitTitle': 'AI Analizi Limiti',
      'addToDiaryAILimitMessage': 'Ücretsiz kullanıcılar haftada {limit} AI analizi yapabilir.',
      'addToDiaryAILimitUsage': 'Bu hafta {used}/{limit} analiz yaptınız.',
      'addToDiaryAILimitUpgrade': 'Premium\'a geçerek sınırsız AI analizi yapabilirsiniz!',
      'addToDiaryFoodDescription': 'Yemek Açıklaması',
      'addToDiaryFoodDescriptionHint': 'Örnek: Domates biber ile menemen yaptım, 2 yumurta kullandım...',
      'addToDiaryDescriptionRequired': 'Açıklama gereklidir',
      'addToDiaryAnalyzeWithAI': 'AI ile Analiz Et',
      'addToDiaryAnalyzing': 'AI Analiz Ediliyor...',
      'addToDiaryAIResult': 'AI Analiz Sonucu',
      'addToDiaryCalories': '{calories} Kalori',
      'addToDiaryMealName': 'Öğün Adı',
      'addToDiaryMealNameHint': 'Öğün için bir isim verin',
      'addToDiaryMealNameRequired': 'Öğün adı gereklidir',
      'addToDiaryAddToJournal': 'Öğünü Günlüğe Ekle',
      'addToDiaryEnterFoodDescription': 'Lütfen yemek açıklaması girin',
      'addToDiaryAIAnalysisComplete': 'AI analizi başarıyla tamamlandı',
      'addToDiaryAnalysisError': 'Analiz başarısız, lütfen tekrar deneyin',
      'addToDiaryAnalysisRequired': 'Lütfen önce yemeği analiz edin',
      'addToDiaryMealAddedSuccessfully': 'Öğün başarıyla eklendi',
      'addToDiaryMealAddError': 'Öğün eklenemedi',
      'addToDiaryCalorieWarning': 'Kalori Sınırı Uyarısı',
      'addToDiaryCalorieWarningMessage': 'Bu öğün {mealType} için önerilen kalori sınırını aşıyor.',
      'addToDiaryAddAnyway': 'Yine de Ekle',
      
      // Meal Options
      'mealOatmealBerries': 'Meyveli Yulaf Ezmesi',
      'mealOatmealBerriesDesc': 'Karışık meyveli ve ballı yulaf ezmesi',
      'mealGreekYogurt': 'Yunan Yoğurdu Parfesi',
      'mealGreekYogurtDesc': 'Granola ve meyveli katmanlı Yunan yoğurdu',
      'mealAvocadoToast': 'Avokado Tost',
      'mealAvocadoToastDesc': 'Ezilmiş avokadolu tam tahıllı ekmek',
      'mealScrambledEggs': 'Çırpılmış Yumurta',
      'mealScrambledEggsDesc': 'Otlu çırpılmış iki yumurta',
      'mealGrilledChickenSalad': 'Izgara Tavuk Salatası',
      'mealGrilledChickenSaladDesc': 'Izgara tavuk göğsü ile karışık yeşillik',
      'mealQuinoaBowl': 'Kinoa Kasesi',
      'mealQuinoaBowlDesc': 'Kavrulmuş sebzeli ve tahinli kinoa',
      'mealTurkeySandwich': 'Hindi Sandviç',
      'mealTurkeySandwichDesc': 'Sebzeli hindi sandviç tam tahıllı ekmekte',
      'mealLentilSoup': 'Mercimek Çorbası',
      'mealLentilSoupDesc': 'Sebzeli doyurucu mercimek çorbası',
      'mealGrilledSalmon': 'Izgara Somon',
      'mealGrilledSalmonDesc': 'Kavrulmuş sebzeli izgara somon',
      'mealChickenStirFry': 'Tavuk Sote',
      'mealChickenStirFryDesc': 'Hafif soslu karışık sebzeli tavuk',
      'mealVegetableCurry': 'Sebze Köri',
      'mealVegetableCurryDesc': 'Hindistan cevizi sütlü karışık sebze köri',
      'mealPastaPrimavera': 'Primavera Makarna',
      'mealPastaPrimaveraDesc': 'Mevsim sebzeli tam tahıllı makarna',
      'mealMixedNuts': 'Karışık Kuruyemiş',
      'mealMixedNutsDesc': 'Bir avuç karışık kuruyemiş',
      'mealApplePeanutButter': 'Fıstık Ezmeli Elma',
      'mealApplePeanutButterDesc': 'Doğal fıstık ezmeli dilimlenmiş elma',
      'mealProteinSmoothie': 'Protein Smoothie',
      'mealProteinSmoothieDesc': 'Meyveli protein smoothie',
      'mealHummusVegetables': 'Sebzeli Humus',
      'mealHummusVegetablesDesc': 'Humus soslu taze sebzeler',
      
      // Additional strings that might be referenced
      'enterFoodDescription': 'Lütfen yemek açıklaması girin',
      'aiAnalysisComplete': 'AI analizi başarıyla tamamlandı',
      'analysisError': 'Analiz başarısız, lütfen tekrar deneyin',
      'analysisRequired': 'Lütfen önce yemeği analiz edin',
      'mealAddedSuccessfully': 'Öğün başarıyla eklendi',
      'mealAddError': 'Öğün eklenemedi',
    };
  }
} 