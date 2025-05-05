import 'package:hive/hive.dart';

class HistoryEntry {
  HistoryEntry({
    required this.userId,
    required this.image,
    required this.diseaseName,
    required this.confidence,
    required this.recommendations,
    required this.date,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    userId: json['userId'] as String,
    image: json['image'] as String,
    diseaseName: json['diseaseName'] as String,
    confidence: json['confidence'] as double,
    recommendations: json['recommendations'] as String,
    date: DateTime.parse(json['date'] as String),
  );

  final String id = DateTime.now().millisecondsSinceEpoch.toString();
  final String userId;
  final String image;
  final String diseaseName;
  final double confidence;
  final String recommendations;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'image': image,
    'diseaseName': diseaseName,
    'confidence': confidence,
    'recommendations': recommendations,
    'date': date.toIso8601String(),
  };
}

class StorageUtil {
  static const String _boxName = 'historyBox';

  static Future<void> saveHistoryEntry(HistoryEntry entry) async {
    final box = await Hive.openBox(_boxName);
    final historyList =
        box.get(entry.userId, defaultValue: <Map<String, dynamic>>[]) as List;
    historyList.add(entry.toJson());
    await box.put(entry.userId, historyList);
  }

  static Future<List<HistoryEntry>> getHistoryEntries(String userId) async {
    final box = await Hive.openBox(_boxName);
    final rawList =
        box.get(userId, defaultValue: <Map<String, dynamic>>[]) as List;
    return rawList
        .map((e) => HistoryEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> clearHistory() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }

  static Future<void> removeElement(String userId, String elementId) async {
    final box = await Hive.openBox(_boxName);
    final historyList =
        box.get(userId, defaultValue: <Map<String, dynamic>>[]) as List;
    var targetEntry = historyList.firstWhere(
      (entry) => entry['id'] == elementId,
    );
    historyList.remove(targetEntry);
    await box.put(userId, historyList);
  }
}
