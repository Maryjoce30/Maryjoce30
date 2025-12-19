import 'package:cloud_firestore/cloud_firestore.dart';

class ClassificationHistory {
  final String id;
  final String productName;
  final double confidence;
  final DateTime timestamp;
  final String imagePath;
  final bool isFavorite;

  ClassificationHistory({
    required this.id,
    required this.productName,
    required this.confidence,
    required this.timestamp,
    required this.imagePath,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'confidence': confidence,
      'timestamp': timestamp,
      'imagePath': imagePath,
      'isFavorite': isFavorite,
    };
  }

  factory ClassificationHistory.fromMap(Map<String, dynamic> map) {
    return ClassificationHistory(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      confidence: map['confidence']?.toDouble() ?? 0.0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      imagePath: map['imagePath'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  ClassificationHistory copyWith({
    String? id,
    String? productName,
    double? confidence,
    DateTime? timestamp,
    String? imagePath,
    bool? isFavorite,
  }) {
    return ClassificationHistory(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
