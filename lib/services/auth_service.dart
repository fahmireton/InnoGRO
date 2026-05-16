import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;
  static final _google = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static Future<UserCredential> registerWithEmail(
      String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user!.updateDisplayName(name);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'region': 'Malaysia',
      'joinedAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      // Create user doc if new
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(cred.user!.uid).set({
          'name': cred.user!.displayName ?? 'Farmer',
          'email': cred.user!.email ?? '',
          'region': 'Malaysia',
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }
      return cred;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }
}
