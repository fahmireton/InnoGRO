import 'package:flutter/material.dart';

// 6 stages matching the source exactly
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

  // Gradient colors for field card header
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
  });
}

List<PaddyField> sampleFields = [
  PaddyField(
    id: '1',
    name: 'Sawah Utara',
    location: 'Kedah, Malaysia',
    areaMorgen: 2.5,
    stage: GrowthStage.tillering,
    healthStatus: HealthStatus.watch,
    waterLevel: 72,
    fertilizerLevel: 55,
    healthScore: 74,
    plantedDate: DateTime.now().subtract(const Duration(days: 32)),
    activityLog: [
      'Applied urea fertiliser (60kg/ha)',
      'Water level adjusted to 5cm',
      'Planted certified MR219 seeds',
    ],
    scanHistory: [
      ScanRecord(
        diseaseName: 'Brown Spot',
        severity: 'Medium',
        date: DateTime.now().subtract(const Duration(days: 5)),
        confidence: 89.7,
      ),
    ],
    variety: 'MR219',
    latitude: 6.1184,
    longitude: 100.3685,
  ),
  PaddyField(
    id: '2',
    name: 'Sawah Selatan',
    location: 'Kedah, Malaysia',
    areaMorgen: 1.8,
    stage: GrowthStage.ripening,
    healthStatus: HealthStatus.healthy,
    waterLevel: 80,
    fertilizerLevel: 75,
    healthScore: 91,
    plantedDate: DateTime.now().subtract(const Duration(days: 58)),
    activityLog: [
      'Pest check — all clear',
      'Applied potassium supplement',
      'Irrigation system checked',
      'Planted MR263 variety',
    ],
    scanHistory: [],
    variety: 'MR263',
    latitude: 6.1100,
    longitude: 100.3600,
  ),
];
