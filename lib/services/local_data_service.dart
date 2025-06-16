import 'package:hive_flutter/hive_flutter.dart';

class LocalDataService {
  static const String _userProfileBox = 'user_profile';
  static const String _dailyMealsBox = 'daily_meals';
  static const String _aiSuggestionsBox = 'ai_suggestions';
  static const String _userStatsBox = 'user_stats';

  // Initialize Hive boxes
  static Future<void> initialize() async {
    await Hive.openBox(_userProfileBox);
    await Hive.openBox(_dailyMealsBox);
    await Hive.openBox(_aiSuggestionsBox);
    await Hive.openBox(_userStatsBox);
    print('✅ Local data service initialized');
  }

  // Kullanıcı profil bilgilerini kaydet
  static Future<void> saveUserProfile({
    required String name,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String activityLevel,
    required String goal,
    required int targetCalories,
  }) async {
    try {
      final box = Hive.box(_userProfileBox);
      await box.put('profile', {
        'name': name,
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
        'activityLevel': activityLevel,
        'goal': goal,
        'targetCalories': targetCalories,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ User profile saved locally');
    } catch (e) {
      print('❌ Error saving user profile locally: $e');
      throw e;
    }
  }

  // Günlük yemek verilerini kaydet
  static Future<void> saveDailyMeals({
    required DateTime date,
    required List<Map<String, dynamic>> meals,
    required int totalCalories,
    required Map<String, double> macros,
  }) async {
    try {
      final box = Hive.box(_dailyMealsBox);
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      await box.put(dateStr, {
        'date': dateStr,
        'meals': meals,
        'totalCalories': totalCalories,
        'macros': macros,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ Daily meals saved locally for $dateStr');
    } catch (e) {
      print('❌ Error saving daily meals locally: $e');
      throw e;
    }
  }

  // AI menü önerilerini kaydet
  static Future<void> saveAIMenuSuggestion({
    required DateTime date,
    required Map<String, dynamic> menuData,
  }) async {
    try {
      final box = Hive.box(_aiSuggestionsBox);
      final key = '${date.millisecondsSinceEpoch}';
      
      await box.put(key, {
        'date': date.toIso8601String(),
        'menuData': menuData,
        'createdAt': DateTime.now().toIso8601String(),
      });
      print('✅ AI menu suggestion saved locally');
    } catch (e) {
      print('❌ Error saving AI menu suggestion locally: $e');
      throw e;
    }
  }

  // Kullanıcı profilini getir
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final box = Hive.box(_userProfileBox);
      final data = box.get('profile');
      return data?.cast<String, dynamic>();
    } catch (e) {
      print('❌ Error getting user profile locally: $e');
      return null;
    }
  }

  // Günlük yemek verilerini getir
  static Future<Map<String, dynamic>?> getDailyMeals(DateTime date) async {
    try {
      final box = Hive.box(_dailyMealsBox);
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final data = box.get(dateStr);
      return data?.cast<String, dynamic>();
    } catch (e) {
      print('❌ Error getting daily meals locally: $e');
      return null;
    }
  }

  // Kullanıcı istatistiklerini kaydet
  static Future<void> saveUserStats({
    required DateTime date,
    required double weight,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final box = Hive.box(_userStatsBox);
      final key = date.millisecondsSinceEpoch.toString();
      
      await box.put(key, {
        'date': date.toIso8601String(),
        'weight': weight,
        'additionalData': additionalData ?? {},
        'createdAt': DateTime.now().toIso8601String(),
      });
      print('✅ User stats saved locally');
    } catch (e) {
      print('❌ Error saving user stats locally: $e');
      throw e;
    }
  }

  // Son 30 günün istatistiklerini getir
  static Future<List<Map<String, dynamic>>> getRecentStats({int days = 30}) async {
    try {
      final box = Hive.box(_userStatsBox);
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final allStats = <Map<String, dynamic>>[];
      
      for (final key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          final dateStr = data['date'] as String?;
          if (dateStr != null) {
            final date = DateTime.parse(dateStr);
            if (date.isAfter(cutoffDate)) {
              allStats.add({
                'id': key,
                ...data.cast<String, dynamic>(),
              });
            }
          }
        }
      }
      
      // Tarihe göre sırala (en yeni önce)
      allStats.sort((a, b) {
        final dateA = DateTime.parse(a['date']);
        final dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);
      });
      
      return allStats;
    } catch (e) {
      print('❌ Error getting recent stats locally: $e');
      return [];
    }
  }

  // Tüm verileri temizle (çıkış yaparken)
  static Future<void> clearAllData() async {
    try {
      await Hive.box(_userProfileBox).clear();
      await Hive.box(_dailyMealsBox).clear();
      await Hive.box(_aiSuggestionsBox).clear();
      await Hive.box(_userStatsBox).clear();
      print('✅ All local data cleared');
    } catch (e) {
      print('❌ Error clearing local data: $e');
    }
  }

  // Veri senkronizasyon durumu
  static Future<void> markDataForSync(String dataType, String key) async {
    try {
      final box = await Hive.openBox('sync_queue');
      final syncQueue = box.get('queue', defaultValue: <String>[]) as List<String>;
      final syncKey = '$dataType:$key';
      
      if (!syncQueue.contains(syncKey)) {
        syncQueue.add(syncKey);
        await box.put('queue', syncQueue);
      }
    } catch (e) {
      print('❌ Error marking data for sync: $e');
    }
  }

  // Senkronize edilecek verileri getir
  static Future<List<String>> getSyncQueue() async {
    try {
      final box = await Hive.openBox('sync_queue');
      return (box.get('queue', defaultValue: <String>[]) as List<dynamic>).cast<String>();
    } catch (e) {
      print('❌ Error getting sync queue: $e');
      return [];
    }
  }

  // Senkronizasyon kuyruğunu temizle
  static Future<void> clearSyncQueue() async {
    try {
      final box = await Hive.openBox('sync_queue');
      await box.put('queue', <String>[]);
    } catch (e) {
      print('❌ Error clearing sync queue: $e');
    }
  }
} 