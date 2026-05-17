import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum GrowthStage { seedling, vegetative, tillering, flowering, ripening, harvest }

extension GrowthStageX on GrowthStage {
  String get label => const {
    GrowthStage.seedling: 'Seedling',
    GrowthStage.vegetative: 'Vegetative',
    GrowthStage.tillering: 'Tillering',
    GrowthStage.flowering: 'Flowering',
    GrowthStage.ripening: 'Ripening',
    GrowthStage.harvest: 'Harvest',
  }[this]!;

  String get dayRange => const {
    GrowthStage.seedling: '0–20 days',
    GrowthStage.vegetative: '20–45 days',
    GrowthStage.tillering: '45–65 days',
    GrowthStage.flowering: '65–85 days',
    GrowthStage.ripening: '85–110 days',
    GrowthStage.harvest: '110+ days',
  }[this]!;

  String get note => const {
    GrowthStage.seedling: 'Nursery: ensure clean seed and shaded warmth.',
    GrowthStage.vegetative: 'Top dressing nitrogen; watch for stem borers.',
    GrowthStage.tillering: 'Critical water — keep 5cm flooded depth.',
    GrowthStage.flowering: 'Most vulnerable to blast; preventive spray helps.',
    GrowthStage.ripening: 'Drain field 10 days before harvest.',
    GrowthStage.harvest: 'Harvest in morning for best grain quality.',
  }[this]!;

  String get emoji => const {
    GrowthStage.seedling: '🌱',
    GrowthStage.vegetative: '🌿',
    GrowthStage.tillering: '🎋',
    GrowthStage.flowering: '🌸',
    GrowthStage.ripening: '🌾',
    GrowthStage.harvest: '🌾',
  }[this]!;

  String get shortLabel => const {
    GrowthStage.seedling: 'Seed',
    GrowthStage.vegetative: 'Baby Plant',
    GrowthStage.tillering: 'Growing',
    GrowthStage.flowering: 'Flowering',
    GrowthStage.ripening: 'Mature',
    GrowthStage.harvest: 'Harvest',
  }[this]!;

  String get description => const {
    GrowthStage.seedling: 'The seed is planted and waiting to sprout.',
    GrowthStage.vegetative: 'The plant has sprouted and is developing its first leaves.',
    GrowthStage.tillering: 'The plant is growing taller and getting stronger.',
    GrowthStage.flowering: 'The plant is entering its flowering phase.',
    GrowthStage.ripening: 'The plant is fully grown and almost ready to harvest.',
    GrowthStage.harvest: 'Time to harvest! Enjoy your healthy crops.',
  }[this]!;

  double get progress => const {
    GrowthStage.seedling: 0.0,
    GrowthStage.vegetative: 0.2,
    GrowthStage.tillering: 0.4,
    GrowthStage.flowering: 0.6,
    GrowthStage.ripening: 0.82,
    GrowthStage.harvest: 1.0,
  }[this]!;

  Color get color => const {
    GrowthStage.seedling: Color(0xFF81C784),
    GrowthStage.vegetative: Color(0xFF4CAF50),
    GrowthStage.tillering: Color(0xFF2E7D32),
    GrowthStage.flowering: Color(0xFFCE93D8),
    GrowthStage.ripening: Color(0xFFF9A825),
    GrowthStage.harvest: Color(0xFFE65100),
  }[this]!;
}

enum HealthStatus { healthy, watch, critical }

extension HealthStatusX on HealthStatus {
  String get label => const {
    HealthStatus.healthy: 'Healthy',
    HealthStatus.watch: 'Watch',
    HealthStatus.critical: 'Critical',
  }[this]!;

  Color get color => const {
    HealthStatus.healthy: Color(0xFF52B788),
    HealthStatus.watch: Color(0xFFF59E0B),
    HealthStatus.critical: Color(0xFFDC2626),
  }[this]!;

  Color get bgColor => const {
    HealthStatus.healthy: Color(0xFFDCFCE7),
    HealthStatus.watch: Color(0xFFFFF3CD),
    HealthStatus.critical: Color(0xFFFEE2E2),
  }[this]!;

  Color get gradientStart => const {
    HealthStatus.healthy: Color(0xFF1E8C58),
    HealthStatus.watch: Color(0xFFCC7A08),
    HealthStatus.critical: Color(0xFFBB2020),
  }[this]!;

  Color get gradientEnd => const {
    HealthStatus.healthy: Color(0xFF9EEDC4),
    HealthStatus.watch: Color(0xFFF9D870),
    HealthStatus.critical: Color(0xFFF4A0A0),
  }[this]!;
}

class ScanRecord {
  final String diseaseName;
  final String severity;
  final DateTime date;
  final double confidence;
  const ScanRecord({
    required this.diseaseName,
    required this.severity,
    required this.date,
    required this.confidence,
  });

  Map<String, dynamic> toMap() => {
    'diseaseName': diseaseName,
    'severity': severity,
    'date': Timestamp.fromDate(date),
    'confidence': confidence,
  };

  factory ScanRecord.fromMap(Map<String, dynamic> m) => ScanRecord(
    diseaseName: m['diseaseName'] ?? '',
    severity: m['severity'] ?? '',
    date: m['date'] is Timestamp
        ? (m['date'] as Timestamp).toDate()
        : DateTime.now(),
    confidence: (m['confidence'] ?? 0).toDouble(),
  );
}

class PaddyField {
  final String id;
  String name;
  String location;
  double areaMorgen;
  GrowthStage stage;
  HealthStatus healthStatus;
  int waterLevel;
  int fertilizerLevel;
  int healthScore;
  final DateTime plantedDate;
  List<String> activityLog;
  List<ScanRecord> scanHistory;
  String variety;
  double? latitude;
  double? longitude;
  String? photoUrl;

  PaddyField({
    required this.id,
    required this.name,
    required this.location,
    required this.areaMorgen,
    required this.stage,
    required this.healthStatus,
    required this.waterLevel,
    required this.fertilizerLevel,
    required this.healthScore,
    required this.plantedDate,
    required this.activityLog,
    required this.scanHistory,
    required this.variety,
    this.latitude,
    this.longitude,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'location': location,
    'areaMorgen': areaMorgen,
    'stage': stage.index,
    'healthStatus': healthStatus.index,
    'waterLevel': waterLevel,
    'fertilizerLevel': fertilizerLevel,
    'healthScore': healthScore,
    'plantedDate': Timestamp.fromDate(plantedDate),
    'activityLog': activityLog,
    'scanHistory': scanHistory.map((r) => r.toMap()).toList(),
    'variety': variety,
    'latitude': latitude,
    'longitude': longitude,
    'photoUrl': photoUrl,
  };

  factory PaddyField.fromMap(String id, Map<String, dynamic> m) => PaddyField(
    id: id,
    name: m['name'] ?? '',
    location: m['location'] ?? '',
    areaMorgen: (m['areaMorgen'] ?? 1.0).toDouble(),
    stage: GrowthStage.values[
        (m['stage'] as int? ?? 0).clamp(0, GrowthStage.values.length - 1)],
    healthStatus: HealthStatus.values[
        (m['healthStatus'] as int? ?? 0).clamp(0, HealthStatus.values.length - 1)],
    waterLevel: m['waterLevel'] ?? 50,
    fertilizerLevel: m['fertilizerLevel'] ?? 50,
    healthScore: m['healthScore'] ?? 80,
    plantedDate: m['plantedDate'] is Timestamp
        ? (m['plantedDate'] as Timestamp).toDate()
        : DateTime.now(),
    activityLog: List<String>.from(m['activityLog'] ?? []),
    scanHistory: (m['scanHistory'] as List<dynamic>? ?? [])
        .map((r) => ScanRecord.fromMap(r as Map<String, dynamic>))
        .toList(),
    variety: m['variety'] ?? 'MR219',
    latitude: (m['latitude'] as num?)?.toDouble(),
    longitude: (m['longitude'] as num?)?.toDouble(),
    photoUrl: m['photoUrl'] as String?,
  );
}
