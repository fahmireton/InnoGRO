import 'package:flutter/material.dart';

enum GrowthStage { seedling, tillering, booting, flowering, ripening, harvest }

extension GrowthStageX on GrowthStage {
  String get label => const {
    GrowthStage.seedling: 'Seedling',
    GrowthStage.tillering: 'Tillering',
    GrowthStage.booting: 'Booting',
    GrowthStage.flowering: 'Flowering',
    GrowthStage.ripening: 'Ripening',
    GrowthStage.harvest: 'Ready to Harvest',
  }[this]!;

  String get emoji => const {
    GrowthStage.seedling: '🌱',
    GrowthStage.tillering: '🌿',
    GrowthStage.booting: '🎋',
    GrowthStage.flowering: '🌾',
    GrowthStage.ripening: '🟡',
    GrowthStage.harvest: '✅',
  }[this]!;

  double get progress => const {
    GrowthStage.seedling: 0.1,
    GrowthStage.tillering: 0.3,
    GrowthStage.booting: 0.5,
    GrowthStage.flowering: 0.65,
    GrowthStage.ripening: 0.85,
    GrowthStage.harvest: 1.0,
  }[this]!;

  int get daysToHarvest => const {
    GrowthStage.seedling: 110,
    GrowthStage.tillering: 80,
    GrowthStage.booting: 55,
    GrowthStage.flowering: 35,
    GrowthStage.ripening: 15,
    GrowthStage.harvest: 0,
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
    HealthStatus.healthy: Color(0xFF16A34A),
    HealthStatus.watch: Color(0xFFF59E0B),
    HealthStatus.critical: Color(0xFFDC2626),
  }[this]!;

  Color get bgColor => const {
    HealthStatus.healthy: Color(0xFFDCFCE7),
    HealthStatus.watch: Color(0xFFFFF7ED),
    HealthStatus.critical: Color(0xFFFEE2E2),
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
  ),
  PaddyField(
    id: '2',
    name: 'Sawah Selatan',
    location: 'Kedah, Malaysia',
    areaMorgen: 1.8,
    stage: GrowthStage.booting,
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
  ),
];
