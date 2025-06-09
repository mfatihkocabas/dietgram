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
    return _localizations[languageCode]?[key] ?? key;
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
      'loginSubtitle': 'Sağlıklı yolculuğuna devam et',
      'loginEmail': 'E-posta',
      'loginEmailHint': 'example@domain.com',
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
      'emailRequired': 'E-posta gerekli',
      'emailInvalid': 'Lütfen geçerli bir e-posta girin',
      'passwordRequired': 'Şifre gerekli',
      'passwordTooShort': 'Şifre en az 6 karakter olmalı',
      'loginOr': 'veya',
      'loginContinueAsGuest': 'Misafir olarak devam et',
      'loginGuestSubtitle': 'Hesap oluşturmadan uygulamayı deneyin',
      'resetPasswordTitle': 'Şifre Sıfırla',
      'resetPasswordDescription': 'Şifrenizi sıfırlamak için e-posta adresinizi girin ve şifrenizi sıfırlamak için bir bağlantı göndereceğiz.',
      'resetPasswordSuccess': 'Şifre sıfırlama e-postası gönderildi! Gelen kutunuzu kontrol edin.',
      'cancel': 'İptal',
      'sendResetEmail': 'Şifre Sıfırlama E-postası Gönder',
      'dashboardGoodMorning': 'Günaydın!',
      'dashboardTrackMeals': 'Bugünkü öğünlerinizi takip edin',
      'dashboardSelectedDay': 'Seçili Gün',
      'dashboardViewingDay': 'Bu günün öğünlerini görüntüleniyor',
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
    };
  }
} 