import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/field.dart';

class FieldService {
  static final FieldService _i = FieldService._();
  factory FieldService() => _i;
  FieldService._();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('fields');

  // ── Replay cache ────────────────────────────────────────────────────────────
  // Keeps the last emitted list so any new StreamBuilder subscriber gets data
  // immediately instead of waiting for Firestore to respond.
  List<PaddyField>? _cache;
  StreamSubscription<List<PaddyField>>? _firestoreSub;
  String? _cachedUid;
  final _broadcast = StreamController<List<PaddyField>>.broadcast();

  List<PaddyField>? get cachedFields => _cache;

  Stream<List<PaddyField>> watchFields() {
    final uid = _uid;
    if (_cachedUid != uid) {
      _firestoreSub?.cancel();
      _cache = null;
      _cachedUid = uid;
      _firestoreSub = _col
          .orderBy('plantedDate', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => PaddyField.fromMap(d.id, d.data()))
              .toList())
          .listen((fields) {
            _cache = fields;
            _broadcast.add(fields);
          });
    }
    return _broadcast.stream;
  }

  Future<void> addField(PaddyField f) => _col.doc(f.id).set(f.toMap());

  Future<void> deleteField(String id) => _col.doc(id).delete();

  Future<void> updateField(PaddyField f) => _col.doc(f.id).update(f.toMap());

  /// Seeds 3 realistic demo fields if the user's collection is empty.
  Future<void> ensureDemoData() async {
    final snap = await _col.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final now = DateTime.now();
    final demos = [
      PaddyField(
        id: 'demo_sawah_utara',
        name: 'Sawah Utara',
        location: 'Sekinchan, Selangor',
        areaMorgen: 2.4,
        stage: GrowthStage.vegetative,
        healthStatus: HealthStatus.healthy,
        waterLevel: 75,
        fertilizerLevel: 60,
        healthScore: 88,
        plantedDate: now.subtract(const Duration(days: 32)),
        activityLog: ['Field planted', 'First irrigation done', 'Nitrogen top-dress applied'],
        scanHistory: [],
        variety: 'MR219',
        latitude: 3.6833,
        longitude: 101.0167,
        photoUrl: null,
      ),
      PaddyField(
        id: 'demo_sawah_selatan',
        name: 'Sawah Selatan',
        location: 'Sekinchan, Selangor',
        areaMorgen: 3.1,
        stage: GrowthStage.tillering,
        healthStatus: HealthStatus.watch,
        waterLevel: 55,
        fertilizerLevel: 45,
        healthScore: 63,
        plantedDate: now.subtract(const Duration(days: 58)),
        activityLog: ['Field planted', 'Blast detected — neem spray applied', 'Re-checked after spray'],
        scanHistory: [
          ScanRecord(
            diseaseName: 'Rice Blast',
            severity: 'Medium',
            date: now.subtract(const Duration(days: 8)),
            confidence: 91.0,
          ),
        ],
        variety: 'MR269',
        latitude: 3.6712,
        longitude: 101.0143,
        photoUrl: null,
      ),
      PaddyField(
        id: 'demo_bendang_timur',
        name: 'Bendang Timur',
        location: 'Bagan Datuk, Perak',
        areaMorgen: 1.8,
        stage: GrowthStage.seedling,
        healthStatus: HealthStatus.healthy,
        waterLevel: 80,
        fertilizerLevel: 70,
        healthScore: 95,
        plantedDate: now.subtract(const Duration(days: 15)),
        activityLog: ['New season started', 'Seed nursery set up'],
        scanHistory: [],
        variety: 'MR284',
        latitude: 3.9897,
        longitude: 100.7756,
        photoUrl: null,
      ),
      PaddyField(
        id: 'demo_petak_emas',
        name: 'Petak Emas',
        location: 'Sungai Besar, Selangor',
        areaMorgen: 4.2,
        stage: GrowthStage.ripening,
        healthStatus: HealthStatus.watch,
        waterLevel: 40,
        fertilizerLevel: 85,
        healthScore: 71,
        plantedDate: now.subtract(const Duration(days: 95)),
        activityLog: [
          'Field planted',
          'Mid-season fertiliser applied',
          'Sheath blight spotted — fungicide sprayed',
          'Recovery progressing well',
        ],
        scanHistory: [
          ScanRecord(
            diseaseName: 'Sheath Blight',
            severity: 'Low',
            date: now.subtract(const Duration(days: 18)),
            confidence: 87.0,
          ),
        ],
        variety: 'MR220 CL2',
        latitude: 3.6601,
        longitude: 100.9854,
        photoUrl: null,
      ),
      PaddyField(
        id: 'demo_sawah_lama',
        name: 'Sawah Lama',
        location: 'Alor Setar, Kedah',
        areaMorgen: 3.5,
        stage: GrowthStage.harvest,
        healthStatus: HealthStatus.healthy,
        waterLevel: 20,
        fertilizerLevel: 90,
        healthScore: 92,
        plantedDate: now.subtract(const Duration(days: 128)),
        activityLog: [
          'Season started',
          'All inputs applied on schedule',
          'No disease detected throughout',
          'Ready for harvest — awaiting combine',
        ],
        scanHistory: [],
        variety: 'MR297',
        latitude: 6.1184,
        longitude: 100.3685,
        photoUrl: null,
      ),
    ];

    for (final f in demos) {
      await _col.doc(f.id).set(f.toMap());
    }
  }

  Future<String> uploadPhoto(String fieldId, Uint8List bytes) async {
    final ref = _storage.ref('field_photos/$_uid/$fieldId.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
