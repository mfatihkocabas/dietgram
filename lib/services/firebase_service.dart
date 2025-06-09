import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  // Auth methods
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Profile methods
  static Future<void> createUserProfile(UserProfile profile) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .set(profile.toFirestore());
  }

  static Future<UserProfile?> getUserProfile() async {
    if (currentUserId == null) return null;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      
      if (doc.exists) {
        return UserProfile.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(UserProfile profile) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .update(profile.toFirestore());
  }

  // Meal methods
  static Future<void> addMeal(Meal meal) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('meals')
        .add(meal.toFirestore());
  }

  static Future<List<Meal>> getMealsForDate(DateTime date) async {
    if (currentUserId == null) return [];
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('meals')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .orderBy('date')
          .get();
      
      return snapshot.docs
          .map((doc) => Meal.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting meals: $e');
      return [];
    }
  }

  static Future<void> deleteMeal(String mealId) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('meals')
        .doc(mealId)
        .delete();
  }

  static Future<void> updateMeal(String mealId, Meal meal) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('meals')
        .doc(mealId)
        .update(meal.toFirestore());
  }

  // Stream methods for real-time updates
  static Stream<List<Meal>> getMealsStream(DateTime date) {
    if (currentUserId == null) return Stream.value([]);
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('meals')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Meal.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  static Stream<UserProfile?> getUserProfileStream() {
    if (currentUserId == null) return Stream.value(null);
    
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .map((doc) => doc.exists 
            ? UserProfile.fromFirestore(doc.data()!)
            : null);
  }
} 