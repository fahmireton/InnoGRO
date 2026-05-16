import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Posts ──────────────────────────────────────────────────────────────
  static Stream<QuerySnapshot> postsStream() => _db
      .collection('posts')
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots();

  static Future<void> addPost(String content, String region) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.collection('posts').add({
      'authorId': user.uid,
      'authorName': user.displayName ?? 'Farmer',
      'region': region,
      'content': content,
      'likes': 0,
      'replies': 0,
      'timestamp': FieldValue.serverTimestamp(),
      'cropType': 'Paddy',
    });
  }

  static Future<void> likePost(String postId, int currentLikes) =>
      _db.collection('posts').doc(postId).update({'likes': currentLikes + 1});

  // ── Experts ────────────────────────────────────────────────────────────
  static Stream<QuerySnapshot> expertsStream() =>
      _db.collection('experts').snapshots();

  static Future<void> seedExpertsIfEmpty() async {
    final snap = await _db.collection('experts').limit(1).get();
    if (snap.docs.isNotEmpty) return;
    final experts = [
      {'name': 'Dr. Lim Wei Han', 'institution': 'MARDI', 'specialization': 'Plant Pathology', 'experience': 18, 'available': true},
      {'name': 'Prof. Siti Norzahra', 'institution': 'UPM', 'specialization': 'Agronomy', 'experience': 22, 'available': true},
      {'name': 'Dr. Rajendran Kumar', 'institution': 'DOA Kedah', 'specialization': 'Pest Management', 'experience': 14, 'available': false},
      {'name': 'Dr. Amirul Hakim', 'institution': 'MARDI Seberang Perai', 'specialization': 'Rice Breeding', 'experience': 11, 'available': true},
    ];
    final batch = _db.batch();
    for (final e in experts) {
      batch.set(_db.collection('experts').doc(), e);
    }
    await batch.commit();
  }

  // ── Outbreaks ──────────────────────────────────────────────────────────
  static Stream<QuerySnapshot> outbreaksStream() =>
      _db.collection('outbreaks').snapshots();

  static Future<void> seedOutbreaksIfEmpty() async {
    final snap = await _db.collection('outbreaks').limit(1).get();
    if (snap.docs.isNotEmpty) return;
    final outbreaks = [
      {'disease': 'Blast', 'severity': 'High', 'state': 'Kedah', 'lat': 6.1184, 'lng': 100.3685, 'reportedAt': FieldValue.serverTimestamp()},
      {'disease': 'Brown Spot', 'severity': 'Medium', 'state': 'Selangor', 'lat': 3.3853, 'lng': 101.3167, 'reportedAt': FieldValue.serverTimestamp()},
      {'disease': 'Sheath Blight', 'severity': 'High', 'state': 'Perak', 'lat': 4.5921, 'lng': 101.0901, 'reportedAt': FieldValue.serverTimestamp()},
      {'disease': 'Tungro', 'severity': 'Low', 'state': 'Johor', 'lat': 1.9344, 'lng': 103.3587, 'reportedAt': FieldValue.serverTimestamp()},
      {'disease': 'Bacterial Leaf Blight', 'severity': 'Medium', 'state': 'Pahang', 'lat': 3.8126, 'lng': 103.3256, 'reportedAt': FieldValue.serverTimestamp()},
      {'disease': 'Brown Planthopper', 'severity': 'High', 'state': 'Kelantan', 'lat': 6.1254, 'lng': 102.2381, 'reportedAt': FieldValue.serverTimestamp()},
      {'disease': 'Blast', 'severity': 'Medium', 'state': 'Terengganu', 'lat': 5.3117, 'lng': 103.1324, 'reportedAt': FieldValue.serverTimestamp()},
      {'disease': 'Sheath Rot', 'severity': 'Low', 'state': 'Sabah', 'lat': 5.9788, 'lng': 116.0753, 'reportedAt': FieldValue.serverTimestamp()},
      {'disease': 'Tungro', 'severity': 'Medium', 'state': 'Sarawak', 'lat': 1.5533, 'lng': 110.3592, 'reportedAt': FieldValue.serverTimestamp()},
    ];
    final batch = _db.batch();
    for (final o in outbreaks) {
      batch.set(_db.collection('outbreaks').doc(), o);
    }
    await batch.commit();
  }
}
