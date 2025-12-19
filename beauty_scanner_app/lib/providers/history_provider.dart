import 'package:flutter/material.dart';
import '../models/classification_history.dart';
import '../services/firebase_service.dart';

class HistoryProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<ClassificationHistory> _history = [];
  bool _isLoading = false;
  bool _initialized = false;

  List<ClassificationHistory> get history => _history;
  bool get isLoading => _isLoading;

  HistoryProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      debugPrint('🔐 Starting anonymous sign-in...');
      await _firebaseService.signInAnonymously();
      debugPrint('✅ Anonymous sign-in complete!');
      await fetchHistory();
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Initialization failed: $e');
    }
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await _firebaseService.getClassificationHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToHistory(ClassificationHistory item) async {
    try {
      if (!_initialized) {
        debugPrint('⏳ Waiting for Firebase initialization...');
        await Future.delayed(Duration(milliseconds: 500));
      }
      await _firebaseService.saveClassificationHistory(item);
      _history.insert(0, item);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }

  Future<void> toggleFavorite(String historyId, bool isFavorite) async {
    try {
      await _firebaseService.toggleFavorite(historyId, isFavorite);
      final index = _history.indexWhere((h) => h.id == historyId);
      if (index != -1) {
        _history[index] = _history[index].copyWith(isFavorite: isFavorite);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> deleteHistory(String historyId) async {
    try {
      await _firebaseService.deleteClassificationHistory(historyId);
      _history.removeWhere((h) => h.id == historyId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting history: $e');
    }
  }

  List<ClassificationHistory> get favorites =>
      _history.where((h) => h.isFavorite).toList();
}
