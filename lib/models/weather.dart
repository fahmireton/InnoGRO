import 'package:flutter/material.dart' show Color, IconData, Icons;

class WeatherData {
  final double temp;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final String cityName;
  final DateTime time;

  const WeatherData({
    required this.temp,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.cityName,
    required this.time,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      condition: json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
      cityName: json['name'] as String? ?? 'Your Location',
      time: DateTime.now(),
    );
  }

  factory WeatherData.fromForecastJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      condition: json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
      cityName: '',
      time: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
    );
  }

  /// Disease risk score 0–100 derived from weather conditions.
  int get diseaseRiskScore {
    int risk = 0;
    // High humidity → fungal disease risk
    if (humidity > 85) {
      risk += 35;
    } else if (humidity > 75) {
      risk += 20;
    } else if (humidity > 65) {
      risk += 10;
    }
    // 24–30°C is optimal for most paddy diseases
    if (temp >= 24 && temp <= 30) {
      risk += 25;
    } else if (temp >= 20 && temp < 24) {
      risk += 10;
    }
    // Low wind → poor air circulation
    if (windSpeed < 3) {
      risk += 15;
    } else if (windSpeed < 7) {
      risk += 5;
    }
    // Rain adds risk
    if (condition.toLowerCase().contains('rain')) {
      risk += 20;
    } else if (condition.toLowerCase().contains('drizzle')) {
      risk += 10;
    }
    return risk.clamp(0, 100);
  }

  IconData get weatherIconData {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
        return Icons.water_drop_rounded;
      case 'drizzle':
        return Icons.water_drop_outlined;
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.dehaze_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  Color get weatherIconColor {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const Color(0xFFFFA726);
      case 'rain':
        return const Color(0xFF42A5F5);
      case 'drizzle':
        return const Color(0xFF64B5F6);
      case 'thunderstorm':
        return const Color(0xFF7E57C2);
      case 'snow':
        return const Color(0xFF90CAF9);
      default:
        return const Color(0xFF78909C);
    }
  }
}
