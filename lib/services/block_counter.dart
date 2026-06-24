import 'package:shared_preferences/shared_preferences.dart';

class BlockCounter {
  static String _todayKey() {
    final now = DateTime.now();
    return 'blocks_${now.year}_${now.month}_${now.day}';
  }

  static String _appKey(String app) {
    final now = DateTime.now();
    return 'blocks_${app}_${now.year}_${now.month}_${now.day}';
  }

  static Future<void> increment(String app) async {
    final prefs = await SharedPreferences.getInstance();
    final totalKey = _todayKey();
    final appKey = _appKey(app);
    final total = prefs.getInt(totalKey) ?? 0;
    final appCount = prefs.getInt(appKey) ?? 0;
    await prefs.setInt(totalKey, total + 1);
    await prefs.setInt(appKey, appCount + 1);
  }

  static Future<int> getTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_todayKey()) ?? 0;
  }

  static Future<Map<String, int>> getAllAppCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final apps = ['YouTube', 'Instagram', 'TikTok', 'Facebook', 'Snapchat', 'X', 'Reddit'];
    final Map<String, int> result = {};
    for (final app in apps) {
      result[app] = prefs.getInt(_appKey(app)) ?? 0;
    }
    return result;
  }
}
