import 'package:shared_preferences/shared_preferences.dart';

class TutorialPreferences {
  // Keys for storing tutorial view status
  static const String _landingPageViewedKey = 'landing_page_viewed';
  static const String _nearChartTutorialViewedKey = 'near_chart_tutorial_viewed';
  static const String _scanTutorialViewedKey = 'scan_tutorial_viewed';

  // Check if landing page has been viewed
  static Future<bool> hasViewedLandingPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_landingPageViewedKey) ?? false;
  }

  // Mark landing page as viewed
  static Future<void> setLandingPageViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_landingPageViewedKey, true);
  }

  // Check if near chart tutorial has been viewed
  static Future<bool> hasViewedNearChartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_nearChartTutorialViewedKey) ?? false;
  }

  // Mark near chart tutorial as viewed
  static Future<void> setNearChartTutorialViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nearChartTutorialViewedKey, true);
  }

  // Check if scan tutorial has been viewed
  static Future<bool> hasViewedScanTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_scanTutorialViewedKey) ?? false;
  }

  // Mark scan tutorial as viewed
  static Future<void> setScanTutorialViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_scanTutorialViewedKey, true);
  }

  // Reset all tutorial preferences (for testing)
  static Future<void> resetAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_landingPageViewedKey, false);
    await prefs.setBool(_nearChartTutorialViewedKey, false);
    await prefs.setBool(_scanTutorialViewedKey, false);
  }
}