import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test Ad Unit IDs (Production'da gerçek ID'lerle değiştirin)
  static String get _bannerAdUnitId => kDebugMode
      ? (Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Test banner Android
          : 'ca-app-pub-3940256099942544/2934735716') // Test banner iOS
      : (Platform.isAndroid
          ? 'YOUR_ANDROID_BANNER_AD_UNIT_ID'
          : 'YOUR_IOS_BANNER_AD_UNIT_ID');

  static String get _interstitialAdUnitId => kDebugMode
      ? (Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Test interstitial Android
          : 'ca-app-pub-3940256099942544/4411468910') // Test interstitial iOS
      : (Platform.isAndroid
          ? 'YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID'
          : 'YOUR_IOS_INTERSTITIAL_AD_UNIT_ID');

  static String get _rewardedAdUnitId => kDebugMode
      ? (Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917' // Test rewarded Android
          : 'ca-app-pub-3940256099942544/1712485313') // Test rewarded iOS
      : (Platform.isAndroid
          ? 'YOUR_ANDROID_REWARDED_AD_UNIT_ID'
          : 'YOUR_IOS_REWARDED_AD_UNIT_ID');

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  /// Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    // Request configuration for better ad targeting
    final RequestConfiguration requestConfiguration = RequestConfiguration(
      testDeviceIds: kDebugMode ? ['YOUR_TEST_DEVICE_ID'] : [],
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
    );
    
    MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  }

  /// Load Banner Ad
  void loadBannerAd() {
    // Dispose existing banner ad if any
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
      _isBannerAdLoaded = false;
    }
    
    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            if (kDebugMode) print('Banner ad loaded successfully');
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            ad.dispose();
            _bannerAd = null;
            if (kDebugMode) print('Banner ad failed to load: $error');
          },
          onAdOpened: (ad) {
            if (kDebugMode) print('Banner ad opened');
          },
          onAdClosed: (ad) {
            if (kDebugMode) print('Banner ad closed');
          },
        ),
      );
      
      _bannerAd!.load();
    } catch (e) {
      if (kDebugMode) print('Error creating banner ad: $e');
      _isBannerAdLoaded = false;
      _bannerAd = null;
    }
  }

  /// Load Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          if (kDebugMode) print('Interstitial ad loaded successfully');
          
          // Set full screen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) print('Interstitial ad showed full screen');
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) print('Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              // Load next ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) print('Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          if (kDebugMode) print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  /// Load Rewarded Ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          if (kDebugMode) print('Rewarded ad loaded successfully');
          
          // Set full screen content callback
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) print('Rewarded ad showed full screen');
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) print('Rewarded ad dismissed');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
              // Load next ad
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) print('Rewarded ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          if (kDebugMode) print('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  /// Show Interstitial Ad
  void showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      if (kDebugMode) print('Interstitial ad not ready');
      // Load ad for next time
      loadInterstitialAd();
    }
  }

  /// Show Rewarded Ad
  void showRewardedAd({
    required Function() onUserEarnedReward,
    Function()? onAdDismissed,
  }) {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          if (kDebugMode) print('User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward();
        },
      );
      
      // Override callback for custom dismiss handling
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) print('Rewarded ad dismissed');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          onAdDismissed?.call();
          // Load next ad
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) print('Rewarded ad failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
        },
      );
    } else {
      if (kDebugMode) print('Rewarded ad not ready');
      // Load ad for next time
      loadRewardedAd();
    }
  }

  /// Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }

  /// Preload all ads
  void preloadAds() {
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }
}

/// Ad frequency manager
class AdFrequencyManager {
  static const String _lastInterstitialKey = 'last_interstitial_ad';
  static const String _dailyAdCountKey = 'daily_ad_count';
  static const String _lastAdDateKey = 'last_ad_date';
  
  // Ad frequency settings
  static const int minInterstitialInterval = 60; // seconds
  static const int maxDailyAds = 10;
  
  /// Check if interstitial ad can be shown
  static bool canShowInterstitial() {
    // Implementation would use SharedPreferences
    // For now, return true for demo
    return true;
  }
  
  /// Record interstitial ad shown
  static void recordInterstitialShown() {
    // Implementation would update SharedPreferences
    // Record timestamp and increment daily count
  }
  
  /// Reset daily ad count if new day
  static void checkAndResetDailyCount() {
    // Implementation would check date and reset count if needed
  }
} 