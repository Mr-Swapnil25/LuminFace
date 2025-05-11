import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  String? profileImageUrl;
  List<SkinAnalysis>? skinHistory;
  SkinGoal? skinGoal;
  bool isDarkMode;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    this.profileImageUrl,
    this.skinHistory,
    this.skinGoal,
    this.isDarkMode = false,
  });

  // Create user model from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    List<SkinAnalysis>? skinHistory;
    if (data['skinHistory'] != null) {
      skinHistory = (data['skinHistory'] as List)
          .map((analysis) => SkinAnalysis.fromMap(analysis))
          .toList();
    }

    SkinGoal? skinGoal;
    if (data['skinGoal'] != null) {
      skinGoal = SkinGoal.fromMap(data['skinGoal']);
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      gender: data['gender'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
      skinHistory: skinHistory,
      skinGoal: skinGoal,
      isDarkMode: data['isDarkMode'] ?? false,
    );
  }

  // Convert user model to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'profileImageUrl': profileImageUrl,
      'skinHistory': skinHistory?.map((analysis) => analysis.toMap()).toList(),
      'skinGoal': skinGoal?.toMap(),
      'isDarkMode': isDarkMode,
    };
  }

  // Get user age
  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month || 
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Get age group for Gemini analysis
  String get ageGroup {
    final userAge = age;
    if (userAge < 18) return 'teen';
    if (userAge < 30) return 'young_adult';
    if (userAge < 45) return 'adult';
    if (userAge < 60) return 'mature';
    return 'senior';
  }

  // Copy user with modifications
  UserModel copyWith({
    String? email,
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    String? profileImageUrl,
    List<SkinAnalysis>? skinHistory,
    SkinGoal? skinGoal,
    bool? isDarkMode,
  }) {
    return UserModel(
      uid: this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      skinHistory: skinHistory ?? this.skinHistory,
      skinGoal: skinGoal ?? this.skinGoal,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SkinAnalysis {
  final DateTime dateTime;
  final String imageUrl;
  final String skinTone;
  final double glowScore;
  final Map<String, double> wrinkleZones;
  final Map<String, double> blemishZones;
  final double symmetryScore;
  final List<String> suggestions;

  SkinAnalysis({
    required this.dateTime,
    required this.imageUrl,
    required this.skinTone,
    required this.glowScore,
    required this.wrinkleZones,
    required this.blemishZones,
    required this.symmetryScore,
    required this.suggestions,
  });

  factory SkinAnalysis.fromMap(Map<String, dynamic> map) {
    return SkinAnalysis(
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'] ?? '',
      skinTone: map['skinTone'] ?? '',
      glowScore: map['glowScore']?.toDouble() ?? 0.0,
      wrinkleZones: Map<String, double>.from(map['wrinkleZones'] ?? {}),
      blemishZones: Map<String, double>.from(map['blemishZones'] ?? {}),
      symmetryScore: map['symmetryScore']?.toDouble() ?? 0.0,
      suggestions: List<String>.from(map['suggestions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'imageUrl': imageUrl,
      'skinTone': skinTone,
      'glowScore': glowScore,
      'wrinkleZones': wrinkleZones,
      'blemishZones': blemishZones,
      'symmetryScore': symmetryScore,
      'suggestions': suggestions,
    };
  }
}

class SkinGoal {
  final String type; // e.g., 'reduce_oiliness', 'improve_glow', 'reduce_wrinkles'
  final String description;
  final DateTime startDate;
  final DateTime? targetDate;
  final double initialScore;
  double currentScore;

  SkinGoal({
    required this.type,
    required this.description,
    required this.startDate,
    this.targetDate,
    required this.initialScore,
    required this.currentScore,
  });

  factory SkinGoal.fromMap(Map<String, dynamic> map) {
    return SkinGoal(
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      targetDate: map['targetDate'] != null 
          ? (map['targetDate'] as Timestamp).toDate() 
          : null,
      initialScore: map['initialScore']?.toDouble() ?? 0.0,
      currentScore: map['currentScore']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'initialScore': initialScore,
      'currentScore': currentScore,
    };
  }

  // Calculate progress percentage
  double get progressPercentage {
    return (currentScore - initialScore) / (1.0 - initialScore) * 100;
  }
} 