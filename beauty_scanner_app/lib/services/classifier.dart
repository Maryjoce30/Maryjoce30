import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassificationResult {
  final String label;
  final double confidence;

  ClassificationResult({required this.label, required this.confidence});

  @override
  String toString() {
    return '$label (${(confidence * 100).toStringAsFixed(2)}%)';
  }
}

class Classifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const String modelFileName = 'assets/model/model_unquant.tflite';
  static const String labelFileName = 'assets/model/labels.txt';
  static const int inputSize = 224;

  Classifier() {
    _loadModel();
    _loadLabels();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelFileName);
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString(labelFileName);
      _labels = labelData.split('\n').where((item) => item.isNotEmpty).toList();
      // Remove the index number if present (e.g., "0 lipstick" -> "lipstick")
      _labels = _labels!.map((l) {
        final parts = l.split(' ');
        if (parts.length > 1 && int.tryParse(parts[0]) != null) {
          return l.substring(parts[0].length).trim();
        }
        return l.trim();
      }).toList();
      debugPrint('Labels loaded successfully: $_labels');
    } catch (e) {
      debugPrint('Error loading labels: $e');
    }
  }

  Future<ClassificationResult?> classifyImage(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      debugPrint('Interpreter or labels not loaded');
      return null;
    }

    // 1. Read image
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      debugPrint('Failed to decode image');
      return null;
    }

    // 2. Resize image
    final resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

    // 3. Convert to input tensor
    // Teachable Machine models (unquantized) usually expect Float32 [1, 224, 224, 3]
    // Normalized to [-1, 1] => (value - 127.5) / 127.5
    final input = Float32List(1 * inputSize * inputSize * 3);
    var pixelIndex = 0;
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        // image package 4.x uses Pixel object, need to extract r, g, b
        // Assuming standard RGB order
        input[pixelIndex++] = (pixel.r - 127.5) / 127.5;
        input[pixelIndex++] = (pixel.g - 127.5) / 127.5;
        input[pixelIndex++] = (pixel.b - 127.5) / 127.5;
      }
    }

    // Reshape to [1, 224, 224, 3]
    final inputTensor = input.reshape([1, inputSize, inputSize, 3]);

    // 4. Output tensor
    // Shape [1, num_classes]
    final outputTensor = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

    // 5. Run inference
    _interpreter!.run(inputTensor, outputTensor);

    // 6. Parse result
    final output = outputTensor[0] as List<double>;
    
    // Find max confidence
    double maxConfidence = -1.0;
    int maxIndex = -1;

    for (var i = 0; i < output.length; i++) {
      if (output[i] > maxConfidence) {
        maxConfidence = output[i];
        maxIndex = i;
      }
    }

    if (maxIndex != -1) {
      return ClassificationResult(
        label: _labels![maxIndex],
        confidence: maxConfidence,
      );
    }

    return null;
  }
  
  void close() {
    _interpreter?.close();
  }
}
