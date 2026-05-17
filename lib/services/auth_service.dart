import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Register with email, password, name, and farm details
  Future<UserProfile?> register({
    required String email,
    required String password,
    required String name,
    required String farmName,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Update display name
      await user.updateDisplayName(name);

      // Create user profile in Firestore
      final profile = UserProfile(
        uid: user.uid,
        email: email,
        name: name,
        farmName: farmName,
        location: location,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(profile.toMap());

      return profile;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  // Sign in with email and password
  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      return await getUserProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Sign in failed: $e';
    }
  }

  // Get user profile from Firestore
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.uid).update(profile.toMap());
    } catch (e) {
      throw 'Update failed: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
