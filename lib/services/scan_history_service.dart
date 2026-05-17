import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanHistoryRecord {
  final String id;
  final String diseaseName;
  final double confidence;
  final String severity;
  final DateTime scannedAt;

  ScanHistoryRecord({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'severity': severity,
        'scannedAt': scannedAt.millisecondsSinceEpoch,
      };

  factory ScanHistoryRecord.fromMap(Map<String, dynamic> map) =>
      ScanHistoryRecord(
        id: map['id'] as String,
        diseaseName: map['diseaseName'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        severity: map['severity'] as String,
        scannedAt:
            DateTime.fromMillisecondsSinceEpoch(map['scannedAt'] as int),
      );
}

class ScanHistoryService extends ChangeNotifier {
  static const _key = 'scan_history';
  static final ScanHistoryService _instance = ScanHistoryService._();
  ScanHistoryService._();
  factory ScanHistoryService() => _instance;

  List<ScanHistoryRecord>? _cache;

  Future<List<ScanHistoryRecord>> getScans() async {
    if (_cache != null) return List.from(_cache!);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return _cache = [];
    final list = jsonDecode(raw) as List;
    _cache = list
        .map((e) => ScanHistoryRecord.fromMap(e as Map<String, dynamic>))
        .toList();
    return List.from(_cache!);
  }

  Future<void> addScan(ScanHistoryRecord record) async {
    final scans = await getScans();
    scans.insert(0, record);
    if (scans.length > 30) scans.removeRange(30, scans.length);
    _cache = scans;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(scans.map((s) => s.toMap()).toList()));
    notifyListeners();
  }

  Future<int> countLast30Days() async {
    final scans = await getScans();
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return scans.where((s) => s.scannedAt.isAfter(cutoff)).length;
  }
}
