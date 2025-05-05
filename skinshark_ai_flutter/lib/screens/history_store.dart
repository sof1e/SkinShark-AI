import 'package:skinshark_ai_fixed/utils/imports.dart';

class DetectionHistory {
  static final DetectionHistory _instance = DetectionHistory._internal();
  factory DetectionHistory() => _instance;

  final List<Map<String, String>> _history = [];

  DetectionHistory._internal();

  List<Map<String, String>> get history => _history;

  void addDetection(
    String diseaseName,
    String confidence,
    String recommendations,
  ) {
    _history.add({
      'disease': diseaseName,
      'confidence': confidence,
      'recommendations': recommendations,
    });
  }
}
