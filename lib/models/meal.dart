class Meal {
  final String id;
  final String name;
  final String type; // breakfast, lunch, dinner, snack
  final double calories;
  final DateTime timestamp;
  final String? description;
  final List<String>? ingredients;

  Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.timestamp,
    this.description,
    this.ingredients,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'calories': calories,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'description': description,
      'ingredients': ingredients,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      calories: map['calories']?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      description: map['description'],
      ingredients: map['ingredients'] != null 
          ? List<String>.from(map['ingredients']) 
          : null,
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json) => Meal.fromMap(json);

  Meal copyWith({
    String? id,
    String? name,
    String? type,
    double? calories,
    DateTime? timestamp,
    String? description,
    List<String>? ingredients,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      calories: calories ?? this.calories,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
    );
  }
} 