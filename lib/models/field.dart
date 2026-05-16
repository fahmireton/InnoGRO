import 'package:flutter/material.dart';

enum GrowthStage { seed, babyPlant, growing, mature, harvest }

extension GrowthStageX on GrowthStage {
  String get label => const {
    GrowthStage.seed: 'Seed',
    GrowthStage.babyPlant: 'Baby Plant',
    GrowthStage.growing: 'Growing',
    GrowthStage.mature: 'Mature',
    GrowthStage.harvest: 'Harvest',
  }[this]!;

  String get description => const {
    GrowthStage.seed: 'The seed is planted and waiting to sprout.',
    GrowthStage.babyPlant: 'The plant has sprouted and developing its first leaves.',
    GrowthStage.growing: 'The plant is growing taller and getting stronger.',
    GrowthStage.mature: 'The plant is fully grown and almost ready to harvest.',
    GrowthStage.harvest: 'Time to harvest! Enjoy your healthy crops.',
  }[this]!;

  String get dayRange => const {
    GrowthStage.seed: 'Day 0 – Day 3',
    GrowthStage.babyPlant: 'Day 3 – Day 15',
    GrowthStage.growing: 'Day 15 – Day 45',
    GrowthStage.mature: 'Day 45 – Day 85',
    GrowthStage.harvest: 'Day 85 – Day 95',
  }[this]!;

  String get tip => const {
    GrowthStage.seed: 'Keep the soil moist and ensure good seed coverage.',
    GrowthStage.babyPlant: 'Ensure enough sunlight and water for healthy growth.',
    GrowthStage.growing: 'Maintain adequate water and monitor for any pests.',
    GrowthStage.mature: 'Check the grains. If they are hard and golden, it\'s ready.',
    GrowthStage.harvest: 'Harvest in the morning for the best quality.',
  }[this]!;

  String get emoji => const {
    GrowthStage.seed: '🫘',
    GrowthStage.babyPlant: '🌱',
    GrowthStage.growing: '🌿',
    GrowthStage.mature: '🌾',
    GrowthStage.harvest: '🌾',
  }[this]!;

  double get progress => const {
    GrowthStage.seed: 0.0,
    GrowthStage.babyPlant: 0.25,
    GrowthStage.growing: 0.50,
    GrowthStage.mature: 0.85,
    GrowthStage.harvest: 1.0,
  }[this]!;

  double get iconScale => const {
    GrowthStage.seed: 0.55,
    GrowthStage.babyPlant: 0.70,
    GrowthStage.growing: 0.82,
    GrowthStage.mature: 0.92,
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
  const ScanRecord({required this.diseaseName, required this.severity, required this.date, required this.confidence});
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
    required this.id, required this.name, required this.location,
    required this.areaMorgen, required this.stage, required this.healthStatus,
    required this.waterLevel, required this.fertilizerLevel, required this.healthScore,
    required this.plantedDate, required this.activityLog, required this.scanHistory,
  });
}

List<PaddyField> sampleFields = [
  PaddyField(
    id: '1', name: 'Sawah Utara', location: 'Kedah, Malaysia',
    areaMorgen: 2.5, stage: GrowthStage.growing, healthStatus: HealthStatus.watch,
    waterLevel: 72, fertilizerLevel: 55, healthScore: 74,
    plantedDate: DateTime.now().subtract(const Duration(days: 32)),
    activityLog: ['Applied urea fertiliser (60kg/ha)', 'Water level adjusted to 5cm', 'Planted certified MR219 seeds'],
    scanHistory: [ScanRecord(diseaseName: 'Brown Spot', severity: 'Medium', date: DateTime.now().subtract(const Duration(days: 5)), confidence: 89.7)],
  ),
  PaddyField(
    id: '2', name: 'Sawah Selatan', location: 'Kedah, Malaysia',
    areaMorgen: 1.8, stage: GrowthStage.mature, healthStatus: HealthStatus.healthy,
    waterLevel: 80, fertilizerLevel: 75, healthScore: 91,
    plantedDate: DateTime.now().subtract(const Duration(days: 58)),
    activityLog: ['Pest check — all clear', 'Applied potassium supplement', 'Irrigation system checked', 'Planted MR263 variety'],
    scanHistory: [],
  ),
];
