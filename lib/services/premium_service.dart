import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

enum PremiumTier {
  free,
  premium,
}

class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  // Subscription product IDs (Replace with your actual product IDs)
  static const String monthlyPremiumId = 'dietgram_premium_monthly';
  static const String yearlyPremiumId = 'dietgram_premium_yearly';
  
  // Free tier limitations
  static const int maxDailyCustomMeals = 3;
  static const int maxWeeklyAIAnalysis = 10;
  static const bool showAdsInFreeTier = true;

  // Current user state
  PremiumTier _currentTier = PremiumTier.free;
  int _dailyCustomMealCount = 0;
  int _weeklyAIAnalysisCount = 0;
  DateTime _lastResetDate = DateTime.now();
  
  // In-app purchase
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  Set<String> _productIds = {monthlyPremiumId, yearlyPremiumId};
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;

  // Getters
  PremiumTier get currentTier => _currentTier;
  bool get isPremium => _currentTier == PremiumTier.premium;
  bool get isFree => _currentTier == PremiumTier.free;
  int get dailyCustomMealCount => _dailyCustomMealCount;
  int get weeklyAIAnalysisCount => _weeklyAIAnalysisCount;
  int get remainingCustomMeals => isPremium ? 999 : (maxDailyCustomMeals - _dailyCustomMealCount).clamp(0, maxDailyCustomMeals);
  int get remainingAIAnalysis => isPremium ? 999 : (maxWeeklyAIAnalysis - _weeklyAIAnalysisCount).clamp(0, maxWeeklyAIAnalysis);
  bool get showAds => isFree && showAdsInFreeTier;
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;

  /// Initialize premium service
  Future<void> initialize() async {
    await _loadUserData();
    await _initializeInAppPurchase();
    _checkAndResetCounters();
  }

  /// Initialize in-app purchase
  Future<void> _initializeInAppPurchase() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (_isAvailable) {
      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) => print('Purchase stream error: $error'),
      );
      
      // Load products
      await _loadProducts();
      
      // Restore purchases
      await _restorePurchases();
    }
  }

  /// Load available products
  Future<void> _loadProducts() async {
    if (!_isAvailable) return;
    
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
    
    if (response.notFoundIDs.isNotEmpty) {
      if (kDebugMode) print('Products not found: ${response.notFoundIDs}');
    }
    
    _products = response.productDetails;
    notifyListeners();
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      
      // Verify purchase (in production, verify with your server)
      final bool valid = await _verifyPurchase(purchaseDetails);
      
      if (valid) {
        // Grant premium access
        await _grantPremiumAccess(purchaseDetails.productID);
        
        if (kDebugMode) print('Premium access granted for: ${purchaseDetails.productID}');
      } else {
        if (kDebugMode) print('Invalid purchase: ${purchaseDetails.productID}');
      }
    }
    
    if (purchaseDetails.status == PurchaseStatus.error) {
      _purchasePending = false;
      if (kDebugMode) print('Purchase error: ${purchaseDetails.error}');
    }
    
    if (purchaseDetails.status == PurchaseStatus.pending) {
      _purchasePending = true;
    } else {
      _purchasePending = false;
    }
    
    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
    
    notifyListeners();
  }

  /// Verify purchase (implement server-side verification in production)
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In production, send the purchase token to your server for verification
    // For now, we'll assume all purchases are valid
    return true;
  }

  /// Grant premium access
  Future<void> _grantPremiumAccess(String productId) async {
    _currentTier = PremiumTier.premium;
    await _saveUserData();
    notifyListeners();
  }

  /// Purchase premium subscription
  Future<void> purchasePremium(String productId) async {
    if (!_isAvailable) {
      throw Exception('In-app purchases not available');
    }
    
    ProductDetails? productDetails;
    try {
      productDetails = _products.firstWhere(
        (product) => product.id == productId,
      );
    } catch (e) {
      throw Exception('Product not found');
    }
    
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    try {
      _purchasePending = true;
      notifyListeners();
      
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _purchasePending = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Restore purchases
  Future<void> _restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      if (kDebugMode) print('Restore purchases error: $e');
    }
  }

  /// Check if user can add custom meal
  bool canAddCustomMeal() {
    if (isPremium) return true;
    return _dailyCustomMealCount < maxDailyCustomMeals;
  }

  /// Check if user can use AI analysis
  bool canUseAIAnalysis() {
    if (isPremium) return true;
    return _weeklyAIAnalysisCount < maxWeeklyAIAnalysis;
  }

  /// Increment custom meal count
  void incrementCustomMealCount() {
    if (!isPremium) {
      _dailyCustomMealCount++;
      _saveUserData();
      notifyListeners();
    }
  }

  /// Increment AI analysis count
  void incrementAIAnalysisCount() {
    if (!isPremium) {
      _weeklyAIAnalysisCount++;
      _saveUserData();
      notifyListeners();
    }
  }

  /// Check and reset daily/weekly counters
  void _checkAndResetCounters() {
    final now = DateTime.now();
    final lastReset = _lastResetDate;
    
    // Reset daily counter if new day
    if (now.day != lastReset.day || 
        now.month != lastReset.month || 
        now.year != lastReset.year) {
      _dailyCustomMealCount = 0;
    }
    
    // Reset weekly counter if new week
    final daysSinceLastReset = now.difference(lastReset).inDays;
    if (daysSinceLastReset >= 7) {
      _weeklyAIAnalysisCount = 0;
    }
    
    _lastResetDate = now;
    _saveUserData();
  }

  /// Load user data from storage
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final tierIndex = prefs.getInt('premium_tier') ?? 0;
    _currentTier = PremiumTier.values[tierIndex];
    
    _dailyCustomMealCount = prefs.getInt('daily_custom_meal_count') ?? 0;
    _weeklyAIAnalysisCount = prefs.getInt('weekly_ai_analysis_count') ?? 0;
    
    final lastResetTimestamp = prefs.getInt('last_reset_date') ?? DateTime.now().millisecondsSinceEpoch;
    _lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp);
  }

  /// Save user data to storage
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('premium_tier', _currentTier.index);
    await prefs.setInt('daily_custom_meal_count', _dailyCustomMealCount);
    await prefs.setInt('weekly_ai_analysis_count', _weeklyAIAnalysisCount);
    await prefs.setInt('last_reset_date', _lastResetDate.millisecondsSinceEpoch);
  }

  /// Get premium features list
  List<String> getPremiumFeatures() {
    return [
      'Sınırsız özel yemek ekleme',
      'Sınırsız AI analizi',
      'Reklamsız deneyim',
      'Gelişmiş beslenme raporları',
      'Özel diyet planları',
      'Öncelikli müşteri desteği',
    ];
  }

  /// Get pricing info
  String getPriceForProduct(String productId) {
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found'),
    );
    return product.price;
  }

  /// Dispose
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// For testing - grant premium access
  Future<void> grantPremiumForTesting() async {
    if (kDebugMode) {
      _currentTier = PremiumTier.premium;
      await _saveUserData();
      notifyListeners();
    }
  }

  /// For testing - revoke premium access
  Future<void> revokePremiumForTesting() async {
    if (kDebugMode) {
      _currentTier = PremiumTier.free;
      await _saveUserData();
      notifyListeners();
    }
  }
} 