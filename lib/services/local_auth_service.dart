import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Local authentication service using SharedPreferences
/// Perfect for demo/hackathon without Firebase setup
class AuthService {
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyUsers = 'users_data';

  // Get current user ID
  Future<String?> get currentUserId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUserId);
  }

  // Check if user is logged in
  Future<bool> get isLoggedIn async {
    final uid = await currentUserId;
    return uid != null;
  }

  // Register with email and password
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
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final usersJson = prefs.getString(_keyUsers) ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));

      // Check if email already exists
      for (var userData in users.values) {
        if (userData['email'] == email) {
          throw 'Email already registered. Please sign in.';
        }
      }

      // Validate password
      if (password.length < 6) {
        throw 'Password must be at least 6 characters.';
      }

      // Create new user ID
      final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';

      // Create user profile
      final profile = UserProfile(
        uid: uid,
        email: email,
        name: name,
        farmName: farmName,
        location: location,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
      );

      // Store user data with password (demo only!)
      final userData = profile.toMap();
      userData['password'] = password;
      users[uid] = userData;

      // Save to SharedPreferences
      await prefs.setString(_keyUsers, json.encode(users));
      await prefs.setString(_keyCurrentUserId, uid);

      return profile;
    } catch (e) {
      if (e is String) rethrow;
      throw 'Registration failed. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyUsers) ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));

      // Find user by email
      for (var entry in users.entries) {
        final userData = entry.value;
        if (userData['email'] == email) {
          // Check password
          if (userData['password'] == password) {
            // Login successful
            await prefs.setString(_keyCurrentUserId, entry.key);
            userData.remove('password');
            return UserProfile.fromMap(userData, entry.key);
          } else {
            throw 'Incorrect password.';
          }
        }
      }

      throw 'No account found with this email.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Sign in failed. Please try again.';
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyUsers) ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));

      if (users.containsKey(uid)) {
        final userData = Map<String, dynamic>.from(users[uid]);
        userData.remove('password');
        return UserProfile.fromMap(userData, uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = await currentUserId;
    if (uid != null) {
      return getUserProfile(uid);
    }
    return null;
  }

  // Update user profile
  Future<void> updateProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyUsers) ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));

      if (users.containsKey(profile.uid)) {
        final oldData = users[profile.uid];
        final userData = profile.toMap();
        userData['password'] = oldData['password']; // Keep password
        users[profile.uid] = userData;
        await prefs.setString(_keyUsers, json.encode(users));
      }
    } catch (e) {
      throw 'Update failed. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUserId);
  }

  // Demo helper: Create test account if needed
  static Future<void> createTestAccountIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_keyUsers) ?? '{}';
    
    if (usersJson == '{}') {
      // Create demo account
      final service = AuthService();
      try {
        await service.register(
          email: 'farmer@innogro.my',
          password: 'demo123',
          name: 'Ahmad Rahman',
          farmName: 'Sawah Pak Ahmad',
          location: 'Sekinchan, Selangor',
          latitude: 3.6873,
          longitude: 101.1554,
        );
        await service.signOut(); // Log out after creating
      } catch (e) {
        // Account might already exist
      }
    }
  }
}
