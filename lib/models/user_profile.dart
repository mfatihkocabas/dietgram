class UserProfile {
  final String id;
  final String name;
  final String email;
  final int age;
  final double weight; // kg
  final double height; // cm
  final String gender; // 'male' or 'female'
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final String goal; // 'lose_weight', 'maintain_weight', 'gain_weight'
  final int dailyCalorieGoal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String preferredLanguage;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.dailyCalorieGoal,
    required this.createdAt,
    required this.updatedAt,
    this.preferredLanguage = 'tr',
  });

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  double get bmr {
    double baseBmr;
    if (gender == 'male') {
      baseBmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      baseBmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }
    return baseBmr;
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  double get tdee {
    double multiplier;
    switch (activityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'light':
        multiplier = 1.375;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'active':
        multiplier = 1.725;
        break;
      case 'very_active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.2;
    }
    return bmr * multiplier;
  }

  // Calculate recommended daily calories based on goal
  int get recommendedDailyCalories {
    switch (goal) {
      case 'lose_weight':
        return (tdee - 500).round(); // 500 calorie deficit for ~1 lb/week loss
      case 'gain_weight':
        return (tdee + 500).round(); // 500 calorie surplus for ~1 lb/week gain
      case 'maintain_weight':
      default:
        return tdee.round();
    }
  }

  // Create from Firestore document
  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      gender: data['gender'] ?? 'male',
      activityLevel: data['activityLevel'] ?? 'sedentary',
      goal: data['goal'] ?? 'maintain_weight',
      dailyCalorieGoal: data['dailyCalorieGoal'] ?? 2000,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
      preferredLanguage: data['preferredLanguage'] ?? 'tr',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activityLevel': activityLevel,
      'goal': goal,
      'dailyCalorieGoal': dailyCalorieGoal,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'preferredLanguage': preferredLanguage,
    };
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? activityLevel,
    String? goal,
    int? dailyCalorieGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? preferredLanguage,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
} 