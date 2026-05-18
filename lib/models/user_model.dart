class AppUser {
  final String uid;
  final String name;
  final String email;
  final int age;
  final double height;
  final double weight;
  final String country;
  final String city;
  final List<String> conditions;
  final List<String> currentMedications;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.height,
    required this.weight,
    required this.country,
    required this.city,
    this.conditions = const ['None'],
    this.currentMedications = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'country': country,
      'city': city,
      'conditions': conditions,
      'currentMedications': currentMedications,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      age: map['age']?.toInt() == 0 ? 25 : (map['age']?.toInt() ?? 25),
      height: map['height']?.toDouble() == 0.0 ? 170.0 : (map['height']?.toDouble() ?? 170.0),
      weight: map['weight']?.toDouble() == 0.0 ? 70.0 : (map['weight']?.toDouble() ?? 70.0),
      country: map['country'] ?? 'Unknown',
      city: map['city'] ?? 'Unknown',
      conditions: List<String>.from(map['conditions'] ?? ['None']),
      currentMedications: List<String>.from(map['currentMedications'] ?? []),
    );
  }

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    int? age,
    double? height,
    double? weight,
    String? country,
    String? city,
    List<String>? conditions,
    List<String>? currentMedications,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      country: country ?? this.country,
      city: city ?? this.city,
      conditions: conditions ?? this.conditions,
      currentMedications: currentMedications ?? this.currentMedications,
    );
  }
}
