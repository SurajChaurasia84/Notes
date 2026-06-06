import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static const String bannerAdUnitId = 'ca-app-pub-9857170190101725/2150642885';
  static const String interstitialAdUnitId = 'ca-app-pub-9857170190101725/7893393925';
  static const String appOpenAdUnitId = 'ca-app-pub-9857170190101725/5898316209';

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Helper to create and load a Banner Ad.
  static BannerAd createBannerAd({
    required VoidCallback onLoaded,
    required void Function(LoadAdError) onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed(error);
        },
      ),
    );
  }

  // Interstitial Ad state
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdLoading = false;

  /// Preloads an Interstitial Ad.
  static void loadInterstitialAd() {
    if (_isInterstitialAdLoading || _interstitialAd != null) return;
    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Preload next interstitial
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Shows the preloaded Interstitial Ad if available.
  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      loadInterstitialAd(); // Try loading one for next time
    }
  }
}

class AppOpenAdManager {
  static AppOpenAd? _appOpenAd;
  static bool _isAdLoading = false;
  static DateTime? _appOpenAdLoadTime;
  
  // Track if we have shown the App Open Ad during this session
  static bool hasShownAdThisSession = false;

  /// Loads an App Open Ad.
  static void loadAd() {
    if (_isAdLoading || isAdAvailable) return;
    _isAdLoading = true;

    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdLoading = false;
          _appOpenAdLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _isAdLoading = false;
          _appOpenAd = null;
        },
      ),
    );
  }

  /// Checks if a valid, cached App Open Ad is available.
  static bool get isAdAvailable {
    if (_appOpenAd == null || _appOpenAdLoadTime == null) return false;
    // Cache remains valid for 4 hours
    return DateTime.now().difference(_appOpenAdLoadTime!).inHours < 4;
  }

  /// Shows the App Open Ad and calls [onDismissed] when completed or failed.
  static void showAdIfAvailable(VoidCallback onDismissed) {
    if (hasShownAdThisSession) {
      onDismissed();
      return;
    }

    if (!isAdAvailable) {
      loadAd();
      onDismissed();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        hasShownAdThisSession = true;
        loadAd(); // Preload next one
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        hasShownAdThisSession = true;
        loadAd();
        onDismissed();
      },
    );

    _appOpenAd!.show();
  }
}

