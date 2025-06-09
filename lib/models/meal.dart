class Meal {
  final String? id; // Firestore document ID
  final String name;
  final String description;
  final double calories; // Changed to double for consistency
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final List<String> ingredients;
  final DateTime date;
  final DateTime createdAt;
  final String? imageUrl;
  final Map<String, double>? nutritionInfo; // protein, carbs, fat, fiber, etc.

  Meal({
    this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.mealType,
    required this.ingredients,
    required this.date,
    required this.createdAt,
    this.imageUrl,
    this.nutritionInfo,
  });

  // Getters for backward compatibility
  DateTime get timestamp => date;
  String get type => mealType;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'mealType': mealType,
      'ingredients': ingredients,
      'date': date.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'nutritionInfo': nutritionInfo,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      mealType: json['mealType'] ?? 'snack',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      imageUrl: json['imageUrl'],
      nutritionInfo: json['nutritionInfo'] != null
          ? Map<String, double>.from(json['nutritionInfo'])
          : null,
    );
  }

  // Create from Firestore document
  factory Meal.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Meal(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      mealType: data['mealType'] ?? 'snack',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      imageUrl: data['imageUrl'],
      nutritionInfo: data['nutritionInfo'] != null
          ? Map<String, double>.from(data['nutritionInfo'])
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'calories': calories,
      'mealType': mealType,
      'ingredients': ingredients,
      'date': date.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'nutritionInfo': nutritionInfo,
    };
  }

  // Create a copy with updated fields
  Meal copyWith({
    String? id,
    String? name,
    String? description,
    double? calories,
    String? mealType,
    List<String>? ingredients,
    DateTime? date,
    DateTime? createdAt,
    String? imageUrl,
    Map<String, double>? nutritionInfo,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      ingredients: ingredients ?? this.ingredients,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
    );
  }

  // Get nutrition value
  double getNutritionValue(String key) {
    return nutritionInfo?[key] ?? 0.0;
  }

  // Formatted time string
  String get timeString {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Check if meal is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
} 