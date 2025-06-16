import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': user.email,
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
        'activityLevel': activityLevel,
        'goal': goal,
        'targetCalories': targetCalories,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user profile: $e');
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
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_meals')
          .doc(dateStr)
          .set({
        'date': dateStr,
        'meals': meals,
        'totalCalories': totalCalories,
        'macros': macros,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving daily meals: $e');
      throw e;
    }
  }

  // AI menü önerilerini kaydet
  static Future<void> saveAIMenuSuggestion({
    required DateTime date,
    required Map<String, dynamic> menuData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ai_suggestions')
          .add({
        'date': Timestamp.fromDate(date),
        'menuData': menuData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving AI menu suggestion: $e');
      throw e;
    }
  }

  // Kullanıcı profilini getir
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Günlük yemek verilerini getir
  static Future<Map<String, dynamic>?> getDailyMeals(DateTime date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_meals')
          .doc(dateStr)
          .get();
          
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting daily meals: $e');
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
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .add({
        'date': Timestamp.fromDate(date),
        'weight': weight,
        'additionalData': additionalData ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving user stats: $e');
      throw e;
    }
  }

  // Son 30 günün istatistiklerini getir
  static Future<List<Map<String, dynamic>>> getRecentStats({int days = 30}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .where('date', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting recent stats: $e');
      return [];
    }
  }
} 