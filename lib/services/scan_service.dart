import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_keys.dart';
import '../models/disease.dart';

class ScanService {
  static const _edgeFunctionUrl = '$kSupabaseUrl/functions/v1/scan-disease';

  static Future<Disease> analyzeImage(List<XFile> images) async {
    return analyzeXFiles(images);
  }

  static Future<Disease> analyzeXFiles(List<XFile> images) async {
    if (images.isEmpty) return _inconclusive('No image provided.');
    try {
      return await _callEdgeFunction(images);
    } catch (e) {
      print('❌ Scan error: $e');
      return _inconclusive('AI analysis failed: ${e.toString()}');
    }
  }

  static Future<Disease> _callEdgeFunction(List<XFile> imageFiles) async {
    final imageDataUrls = <String>[];
    for (final file in imageFiles) {
      final bytes = await file.readAsBytes();
      final mime = _mime(file.path);
      final sizeInMB = bytes.length / (1024 * 1024);
      print('📸 Image: ${file.name}, ${sizeInMB.toStringAsFixed(2)} MB, $mime');
      if (sizeInMB > 20) {
        return _inconclusive(
            'Image too large (${sizeInMB.toStringAsFixed(1)} MB). Max 20 MB.');
      }
      imageDataUrls.add('data:$mime;base64,${base64Encode(bytes)}');
    }

    print('🌐 Calling edge function...');
    final response = await http.post(
      Uri.parse(_edgeFunctionUrl),
      headers: {
        'Authorization': 'Bearer $kSupabaseAnonKey',
        'apikey': kSupabaseAnonKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'images': imageDataUrls}),
    );

    print('🌐 Edge function status: ${response.statusCode}');

    if (response.statusCode == 429) {
      return _inconclusive('Rate limit reached. Please wait a moment and try again.');
    }
    if (response.statusCode != 200) {
      print('❌ Edge function error: ${response.body}');
      return _inconclusive('AI service error (${response.statusCode}). Please try again.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['error'] != null) {
      print('❌ Diagnosis error: ${decoded['error']}');
      return _inconclusive(decoded['error'].toString());
    }

    final diagnosis = decoded['diagnosis'] as Map<String, dynamic>?;
    if (diagnosis == null) {
      return _inconclusive('No diagnosis returned from AI.');
    }

    print('✅ Diagnosis: ${diagnosis['disease_name']} (${diagnosis['status']})');
    return _parseDiagnosis(diagnosis);
  }

  static String _mime(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  static Disease _parseDiagnosis(Map<String, dynamic> d) {
    final status = d['status']?.toString() ?? 'unclear';
    if (status == 'unclear') {
      return _inconclusive(
          d['summary']?.toString() ?? 'Image unclear. Please retake the photo.');
    }

    final name =
        (status == 'healthy') ? 'Healthy' : (d['disease_name']?.toString() ?? 'Unknown');

    String mapSeverity(String? s) {
      switch (s) {
        case 'mild':
          return 'Low';
        case 'moderate':
          return 'Medium';
        case 'severe':
          return 'High';
        default:
          return 'None';
      }
    }

    List<Treatment> parseTreatment(dynamic raw) {
      if (raw == null) return [];
      final t = raw as Map<String, dynamic>;
      final steps =
          (t['steps'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final products =
          (t['products'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final cost = t['est_cost_myr_per_acre'];
      final costStr =
          cost != null ? 'RM ${(cost as num).toStringAsFixed(0)}/acre' : '';
      if (products.isEmpty && steps.isEmpty) return [];
      if (products.isEmpty) {
        return [
          Treatment(
            name: 'Treatment',
            instructions: steps.join(' '),
            estimatedCost: costStr,
            effectivenessRating: 4,
          )
        ];
      }
      return products
          .map((p) => Treatment(
                name: p,
                instructions: steps.join(' '),
                estimatedCost: costStr,
                effectivenessRating: 4,
              ))
          .toList();
    }

    List<String> strList(dynamic v) =>
        v == null ? [] : (v as List).map((e) => e.toString()).toList();

    return Disease(
      id: name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
      name: name,
      scientificName: d['scientific_name']?.toString() ?? '',
      description: d['summary']?.toString() ?? 'No description available.',
      severity: mapSeverity(d['severity']?.toString()),
      confidence: (d['confidence'] as num?)?.toDouble() ?? 0.0,
      symptoms: strList(d['symptoms']),
      causes: strList(d['causes']),
      organicTreatments: parseTreatment(d['organic_treatment']),
      chemicalTreatments: parseTreatment(d['chemical_treatment']),
      prevention: strList(d['prevention']),
      recoveryTime:
          d['recovery_days'] != null ? '${d['recovery_days']} days' : 'Unknown',
      affectedArea: d['crop']?.toString() ?? 'Unknown',
    );
  }

  static Disease _inconclusive(String reason) => Disease(
        id: 'inconclusive',
        name: 'Inconclusive',
        scientificName: '',
        description: '$reason Retake the photo in good natural lighting '
            'with the affected leaf clearly visible and in focus.',
        severity: 'None',
        confidence: 0.0,
        symptoms: [],
        causes: [],
        organicTreatments: [],
        chemicalTreatments: [],
        prevention: [
          'Retake photo in natural daylight',
          'Focus on the most affected leaf area',
          'Ensure the image is sharp and well-lit',
          'Avoid shadows and glare on the leaf',
        ],
        recoveryTime: '',
        affectedArea: '',
      );
}
