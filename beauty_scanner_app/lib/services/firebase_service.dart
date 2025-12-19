import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/classification_history.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInAnonymously() async {
    try {
      debugPrint('🔐 Attempting anonymous sign-in...');
      await _auth.signInAnonymously();
      
      final uid = _auth.currentUser?.uid;
      debugPrint('✅ Signed in anonymously: $uid');
      if (uid == null) {
        throw Exception('User ID is null after sign-in');
      }
    } catch (e) {
      debugPrint('⚠️ Error during sign-in: $e');
      
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        debugPrint('✅ But user is actually signed in: $uid');
        return;
      }
      rethrow;
    }
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<void> saveClassificationHistory(
    ClassificationHistory history,
  ) async {
    try {
      final userId = getCurrentUserId();
      debugPrint('💾 Saving to Firebase... userId: $userId');
      if (userId == null) {
        debugPrint('❌ userId is null!');
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(history.id)
          .set(history.toMap());
      debugPrint('✅ Classification saved to Firebase: ${history.productName}');
    } catch (e) {
      debugPrint('❌ Error saving classification: $e');
      rethrow;
    }
  }

  Future<List<ClassificationHistory>> getClassificationHistory() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ClassificationHistory.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return [];
    }
  }

  Stream<List<ClassificationHistory>> getClassificationHistoryStream() {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return Stream.value([]);

      return _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ClassificationHistory.fromMap(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('Error streaming history: $e');
      return Stream.value([]);
    }
  }

  Future<void> toggleFavorite(String historyId, bool isFavorite) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(historyId)
          .update({'isFavorite': isFavorite});
      debugPrint('Favorite toggled');
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<void> deleteClassificationHistory(String historyId) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(historyId)
          .delete();
      debugPrint('Classification deleted');
    } catch (e) {
      debugPrint('Error deleting classification: $e');
      rethrow;
    }
  }

  Future<List<ClassificationHistory>> getFavoriteClassifications() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .where('isFavorite', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ClassificationHistory.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      return [];
    }
  }
}
