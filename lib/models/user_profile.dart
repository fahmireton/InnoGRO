class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String? farmName;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.farmName,
    this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      email: map['email'] as String,
      name: map['name'] as String,
      farmName: map['farmName'] as String?,
      location: map['location'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'farmName': farmName,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? farmName,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      farmName: farmName ?? this.farmName,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt,
    );
  }
}
