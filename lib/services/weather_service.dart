import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../config/api_keys.dart';
import '../models/weather.dart';

class WeatherService {
  // Default: Sekinchan, Selangor — Malaysia's largest paddy production area
  static const double _defaultLat = 3.6873;
  static const double _defaultLon = 101.1554;
  static const String _base = 'https://api.openweathermap.org/data/2.5';

  static WeatherData? _cachedCurrent;
  static DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 30);

  // Per-location cache: key = normalised city name
  static final Map<String, WeatherData> _locationCache = {};
  static final Map<String, DateTime> _locationCacheTime = {};

  /// Fetch weather for a specific named location (e.g. "Bagan Datuk, Perak").
  /// Uses the district/city part before the first comma as the query.
  static Future<WeatherData> fetchForLocation(String locationName) async {
    final city = locationName.split(',').first.trim();
    final key = city.toLowerCase();

    final cached = _locationCache[key];
    final cachedAt = _locationCacheTime[key];
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheDuration) {
      return cached;
    }

    final url = Uri.parse(
        '$_base/weather?q=${Uri.encodeComponent(city)},MY&appid=$kOpenWeatherKey&units=metric');
    final resp = await http.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final data = WeatherData.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>);
      _locationCache[key] = data;
      _locationCacheTime[key] = DateTime.now();
      return data;
    }
    // Fallback to current GPS weather if city lookup fails
    return fetchCurrent();
  }

  static Future<WeatherData> fetchCurrent() async {
    if (_cachedCurrent != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedCurrent!;
    }
    final (lat, lon) = await _getLocation();
    final url = Uri.parse(
        '$_base/weather?lat=$lat&lon=$lon&appid=$kOpenWeatherKey&units=metric');
    final resp = await http.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final data = WeatherData.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>);
      _cachedCurrent = data;
      _cacheTime = DateTime.now();
      return data;
    }
    throw Exception('Weather API error: ${resp.statusCode}');
  }

  static Future<List<WeatherData>> fetchForecast() async {
    final (lat, lon) = await _getLocation();
    final url = Uri.parse(
        '$_base/forecast?lat=$lat&lon=$lon&appid=$kOpenWeatherKey&units=metric&cnt=8');
    final resp = await http.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return (json['list'] as List)
          .map((e) =>
              WeatherData.fromForecastJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Forecast API error: ${resp.statusCode}');
  }

  static Future<(double, double)> _getLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (_defaultLat, _defaultLon);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      ).timeout(const Duration(seconds: 6));
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return (_defaultLat, _defaultLon);
    }
  }
}
