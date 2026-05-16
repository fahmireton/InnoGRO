import 'package:flutter/material.dart';

enum GrowthStage { seedling, tillering, flowering, ripening, harvest }

extension GrowthStageInfo on GrowthStage {
  String get label {
    switch (this) {
      case GrowthStage.seedling: return 'Seedling';
      case GrowthStage.tillering: return 'Tillering';
      case GrowthStage.flowering: return 'Flowering';
      case GrowthStage.ripening: return 'Ripening';
      case GrowthStage.harvest: return 'Ready to Harvest';
    }
  }

  String get emoji {
    switch (this) {
      case GrowthStage.seedling: return '🌱';
      case GrowthStage.tillering: return '🌿';
      case GrowthStage.flowering: return '🌾';
      case GrowthStage.ripening: return '🟡';
      case GrowthStage.harvest: return '✅';
    }
  }

  double get progress {
    switch (this) {
      case GrowthStage.seedling: return 0.15;
      case GrowthStage.tillering: return 0.35;
      case GrowthStage.flowering: return 0.60;
      case GrowthStage.ripening: return 0.85;
      case GrowthStage.harvest: return 1.0;
    }
  }

  Color get color {
    switch (this) {
      case GrowthStage.seedling: return const Color(0xFF81C784);
      case GrowthStage.tillering: return const Color(0xFF4CAF50);
      case GrowthStage.flowering: return const Color(0xFF2E7D32);
      case GrowthStage.ripening: return const Color(0xFFF9A825);
      case GrowthStage.harvest: return const Color(0xFFE65100);
    }
  }
}

class PaddyField {
  final String id;
  final String name;
  final String location;
  final double areaMorgen;
  GrowthStage stage;
  int waterLevel;
  int fertilizerLevel;
  int healthScore;
  final DateTime plantedDate;
  List<String> activityLog;

  PaddyField({
    required this.id,
    required this.name,
    required this.location,
    required this.areaMorgen,
    required this.stage,
    required this.waterLevel,
    required this.fertilizerLevel,
    required this.healthScore,
    required this.plantedDate,
    required this.activityLog,
  });
}
