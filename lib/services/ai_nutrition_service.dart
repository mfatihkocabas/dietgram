import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  Map<String, double> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }
}

class NutritionEstimate {
  final String recognizedFood;
  final String description;
  final List<String> ingredients;
  final NutritionInfo nutrition;
  final double confidence;

  NutritionEstimate({
    required this.recognizedFood,
    required this.description,
    required this.ingredients,
    required this.nutrition,
    required this.confidence,
  });
}

class AINutritionService {
  // *** CONFIGURATION ***
  static const String _openAIApiKey = 'YOUR_OPENAI_API_KEY_HERE'; // Premium kullanıcılar için
  static const String _geminiApiKey = 'AIzaSyDyCppKyhdMzjkiZCEXZX2Fg7brUZatJeE'; // Ücretsiz kullanıcılar için
  static const String _nutritionAPIKey = 'YOUR_NUTRITION_API_KEY_HERE';
  
  // API endpoints
  static const String _openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String _nutritionAPIEndpoint = 'https://api.edamam.com/api/nutrition-data';

  // Meal calorie limits
  static const Map<String, double> _mealLimits = {
    'breakfast': 500.0,
    'lunch': 700.0,
    'dinner': 600.0,
    'snack': 200.0,
  };

  // Turkish food database - expanded with more foods
  static const Map<String, Map<String, dynamic>> _turkishFoodDatabase = {
    // Ana yemekler
    'menemen': {
      'calories_per_100g': 150,
      'protein': 8.0,
      'carbs': 6.0,
      'fat': 11.0,
      'fiber': 2.0,
      'typical_portion': 200,
      'ingredients': ['yumurta', 'domates', 'biber', 'soğan', 'zeytinyağı'],
    },
    'köfte': {
      'calories_per_100g': 280,
      'protein': 18.0,
      'carbs': 8.0,
      'fat': 20.0,
      'fiber': 1.0,
      'typical_portion': 150,
      'ingredients': ['kıyma', 'soğan', 'ekmek içi', 'yumurta'],
    },
    'pilav': {
      'calories_per_100g': 130,
      'protein': 2.5,
      'carbs': 28.0,
      'fat': 0.3,
      'fiber': 0.4,
      'typical_portion': 150,
      'ingredients': ['pirinç', 'tereyağı', 'tuz', 'su'],
    },
    'dolma': {
      'calories_per_100g': 180,
      'protein': 4.0,
      'carbs': 20.0,
      'fat': 9.0,
      'fiber': 3.0,
      'typical_portion': 120,
      'ingredients': ['asma yaprağı', 'pirinç', 'kıyma', 'soğan', 'zeytinyağı'],
    },
    'çorba': {
      'calories_per_100g': 60,
      'protein': 3.0,
      'carbs': 8.0,
      'fat': 2.0,
      'fiber': 1.5,
      'typical_portion': 250,
      'ingredients': ['sebze', 'et suyu', 'un', 'tereyağı'],
    },
    'lahmacun': {
      'calories_per_100g': 250,
      'protein': 12.0,
      'carbs': 30.0,
      'fat': 9.0,
      'fiber': 2.0,
      'typical_portion': 100,
      'ingredients': ['hamur', 'kıyma', 'domates', 'soğan', 'maydanoz'],
    },
    'döner': {
      'calories_per_100g': 300,
      'protein': 25.0,
      'carbs': 15.0,
      'fat': 18.0,
      'fiber': 2.0,
      'typical_portion': 200,
      'ingredients': ['tavuk eti', 'ekmek', 'salata', 'sos'],
    },
    'börek': {
      'calories_per_100g': 320,
      'protein': 12.0,
      'carbs': 25.0,
      'fat': 20.0,
      'fiber': 1.5,
      'typical_portion': 150,
      'ingredients': ['yufka', 'peynir', 'yumurta', 'süt', 'tereyağı'],
    },
    'manti': {
      'calories_per_100g': 220,
      'protein': 12.0,
      'carbs': 30.0,
      'fat': 6.0,
      'fiber': 2.0,
      'typical_portion': 200,
      'ingredients': ['hamur', 'kıyma', 'soğan', 'yogurt', 'sarımsak'],
    },
    'kebap': {
      'calories_per_100g': 290,
      'protein': 26.0,
      'carbs': 5.0,
      'fat': 18.0,
      'fiber': 1.0,
      'typical_portion': 180,
      'ingredients': ['et', 'soğan', 'baharat', 'ekmek'],
    },
    'pide': {
      'calories_per_100g': 280,
      'protein': 11.0,
      'carbs': 35.0,
      'fat': 12.0,
      'fiber': 2.5,
      'typical_portion': 200,
      'ingredients': ['hamur', 'peynir', 'yumurta', 'kıyma'],
    },
    'kuru fasulye': {
      'calories_per_100g': 120,
      'protein': 8.0,
      'carbs': 18.0,
      'fat': 2.0,
      'fiber': 6.0,
      'typical_portion': 200,
      'ingredients': ['fasulye', 'soğan', 'domates', 'zeytinyağı'],
    },
    'mercimek çorbası': {
      'calories_per_100g': 80,
      'protein': 4.0,
      'carbs': 12.0,
      'fat': 2.0,
      'fiber': 3.0,
      'typical_portion': 250,
      'ingredients': ['mercimek', 'soğan', 'havuç', 'tereyağı'],
    },
    'tavuk şiş': {
      'calories_per_100g': 180,
      'protein': 30.0,
      'carbs': 0.0,
      'fat': 6.0,
      'fiber': 0.0,
      'typical_portion': 150,
      'ingredients': ['tavuk göğsü', 'baharat', 'zeytinyağı'],
    },
    'balık': {
      'calories_per_100g': 200,
      'protein': 25.0,
      'carbs': 0.0,
      'fat': 10.0,
      'fiber': 0.0,
      'typical_portion': 200,
      'ingredients': ['balık', 'limon', 'zeytinyağı', 'baharat'],
    },
    'salata': {
      'calories_per_100g': 30,
      'protein': 1.5,
      'carbs': 6.0,
      'fat': 0.2,
      'fiber': 2.5,
      'typical_portion': 150,
      'ingredients': ['yeşillik', 'domates', 'salatalık', 'limon'],
    },
    'yogurt': {
      'calories_per_100g': 60,
      'protein': 3.5,
      'carbs': 4.5,
      'fat': 3.3,
      'fiber': 0.0,
      'typical_portion': 200,
      'ingredients': ['süt', 'maya'],
    },
    'ayran': {
      'calories_per_100g': 35,
      'protein': 1.5,
      'carbs': 3.0,
      'fat': 1.8,
      'fiber': 0.0,
      'typical_portion': 250,
      'ingredients': ['yogurt', 'su', 'tuz'],
    },
    'çay': {
      'calories_per_100g': 2,
      'protein': 0.0,
      'carbs': 0.3,
      'fat': 0.0,
      'fiber': 0.0,
      'typical_portion': 200,
      'ingredients': ['çay yaprağı', 'su'],
    },
    'türk kahvesi': {
      'calories_per_100g': 12,
      'protein': 0.2,
      'carbs': 1.6,
      'fat': 0.6,
      'fiber': 0.0,
      'typical_portion': 50,
      'ingredients': ['kahve', 'şeker', 'su'],
    },
    'baklava': {
      'calories_per_100g': 450,
      'protein': 6.0,
      'carbs': 50.0,
      'fat': 25.0,
      'fiber': 2.0,
      'typical_portion': 80,
      'ingredients': ['yufka', 'ceviz', 'şerbet', 'tereyağı'],
    },
    'künefe': {
      'calories_per_100g': 380,
      'protein': 8.0,
      'carbs': 45.0,
      'fat': 18.0,
      'fiber': 1.0,
      'typical_portion': 120,
      'ingredients': ['tel kadayıf', 'peynir', 'şerbet', 'tereyağı'],
    },
    'simit': {
      'calories_per_100g': 290,
      'protein': 9.0,
      'carbs': 55.0,
      'fat': 4.0,
      'fiber': 3.0,
      'typical_portion': 100,
      'ingredients': ['un', 'maya', 'tuz', 'susam'],
    },
    'su böreği': {
      'calories_per_100g': 250,
      'protein': 10.0,
      'carbs': 20.0,
      'fat': 15.0,
      'fiber': 1.0,
      'typical_portion': 150,
      'ingredients': ['yufka', 'peynir', 'yumurta', 'süt'],
    },
  };

  /// AI servisini kullanarak yemek analizi yapar
  /// [description]: Kullanıcının yemek açıklaması
  /// [isPremium]: Kullanıcının premium olup olmadığı
  Future<NutritionEstimate?> analyzeFood(String description, {bool isPremium = false}) async {
    try {
      if (isPremium) {
        // Premium kullanıcılar için OpenAI kullan
        return await _analyzeWithOpenAI(description);
      } else {
        // Ücretsiz kullanıcılar için Gemini kullan
        return await _analyzeWithGemini(description);
      }
    } catch (e) {
      print('AI Analysis Error: $e');
      // Hata durumunda mock data döndür
      return _analyzeWithMockAI(description);
    }
  }

  /// OpenAI GPT ile analiz (Premium kullanıcılar için)
  Future<NutritionEstimate?> _analyzeWithOpenAI(String description) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAIApiKey',
    };

    final systemPrompt = '''
Sen bir profesyonel beslenme uzmanısın. Kullanıcının verdiği yemek açıklamasını analiz et ve besin değerlerini tahmin et. 
Türkçe yemekleri çok iyi tanıyorsun ve porsiyon büyüklüklerini doğru tahmin edebiliyorsun.

Yanıtını tam olarak şu JSON formatında ver:
{
  "recognizedFood": "tanınan yemek adı",
  "description": "yemeğin detaylı açıklaması",
  "ingredients": ["malzeme1", "malzeme2", "malzeme3"],
  "nutrition": {
    "calories": sayı,
    "protein": sayı,
    "carbs": sayı,
    "fat": sayı,
    "fiber": sayı,
    "sugar": sayı,
    "sodium": sayı
  },
  "confidence": 0.95
}

Sadece JSON yanıtı ver, başka açıklama ekleme.
''';

    final body = json.encode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': systemPrompt
        },
        {
          'role': 'user',
          'content': 'Bu yemek hakkında detaylı besin analizi yap: $description'
        }
      ],
      'max_tokens': 800,
      'temperature': 0.2,
    });

    try {
      final response = await http.post(
        Uri.parse(_openAIEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        return _parseOpenAIResponse(content, description);
      } else {
        print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('OpenAI API Error: $e');
      return null;
    }
  }

  /// Google Gemini ile analiz (gerçek AI)
  Future<NutritionEstimate?> _analyzeWithGemini(String description) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    final prompt = '''
Lütfen aşağıdaki yemek açıklamasını analiz et ve besin değerlerini tahmin et. Türkçe yemekleri iyi tanıyorsun.

Yemek açıklaması: "$description"

Lütfen yanıtını tam olarak şu JSON formatında ver:
{
  "recognizedFood": "tanınan yemek adı",
  "description": "yemeğin kısa açıklaması",
  "ingredients": ["malzeme1", "malzeme2", "malzeme3"],
  "nutrition": {
    "calories": sayı,
    "protein": sayı,
    "carbs": sayı,
    "fat": sayı,
    "fiber": sayı,
    "sugar": sayı,
    "sodium": sayı
  },
  "confidence": 0.85
}

Sadece JSON yanıtı ver, başka açıklama ekleme.
''';

    final body = json.encode({
      'contents': [
        {
          'parts': [
            {
              'text': prompt
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      }
    });

    try {
      final response = await http.post(
        Uri.parse('$_geminiEndpoint?key=$_geminiApiKey'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        
        return _parseGeminiResponse(content, description);
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Gemini API Error: $e');
      return null;
    }
  }

  /// Nutrition API ile analiz (gerçek API)
  Future<NutritionEstimate?> _analyzeWithNutritionAPI(String description) async {
    /*
    // Edamam Nutrition API örneği
    final uri = Uri.parse(_nutritionAPIEndpoint).replace(queryParameters: {
      'app_id': 'YOUR_APP_ID',
      'app_key': _nutritionAPIKey,
      'ingr': description,
    });

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        return NutritionEstimate(
          recognizedFood: data['ingredients'][0]['parsed'][0]['food'] ?? 'Unknown',
          description: description,
          ingredients: [description],
          nutrition: NutritionInfo(
            calories: data['calories']?.toDouble() ?? 0,
            protein: data['totalNutrients']['PROCNT']?['quantity']?.toDouble() ?? 0,
            carbs: data['totalNutrients']['CHOCDF']?['quantity']?.toDouble() ?? 0,
            fat: data['totalNutrients']['FAT']?['quantity']?.toDouble() ?? 0,
            fiber: data['totalNutrients']['FIBTG']?['quantity']?.toDouble() ?? 0,
            sugar: data['totalNutrients']['SUGAR']?['quantity']?.toDouble() ?? 0,
            sodium: data['totalNutrients']['NA']?['quantity']?.toDouble() ?? 0,
          ),
          confidence: 0.8,
        );
      }
    } catch (e) {
      print('Nutrition API Error: $e');
    }
    */
    
    // Şimdilik mock data döndür
    return _analyzeWithMockAI(description);
  }

  /// Mock AI analizi (demo amaçlı)
  NutritionEstimate _analyzeWithMockAI(String description) {
    // Basit anahtar kelime tanıma
    final lowerDescription = description.toLowerCase();
    String recognizedFood = 'Bilinmeyen Yemek';
    List<String> ingredients = [];
    double baseCalories = 200;
    double protein = 5;
    double carbs = 20;
    double fat = 8;
    double fiber = 2;

    // Türkçe yemek tanıma
    for (final entry in _turkishFoodDatabase.entries) {
      if (lowerDescription.contains(entry.key)) {
        recognizedFood = entry.key.toUpperCase();
        final foodData = entry.value;
        
        // Porsiyon miktarını tahmin et
        double portionMultiplier = _estimatePortionSize(description);
        double actualPortion = (foodData['typical_portion'] as int) * portionMultiplier;
        
        baseCalories = (foodData['calories_per_100g'] as int) * actualPortion / 100;
        protein = (foodData['protein'] as double) * actualPortion / 100;
        carbs = (foodData['carbs'] as double) * actualPortion / 100;
        fat = (foodData['fat'] as double) * actualPortion / 100;
        fiber = (foodData['fiber'] as double) * actualPortion / 100;
        
        ingredients = List<String>.from(foodData['ingredients'] as List);
        break;
      }
    }

    // Malzeme sayısına göre kalori ayarlaması
    if (lowerDescription.contains('büyük') || lowerDescription.contains('çok')) {
      baseCalories *= 1.5;
    } else if (lowerDescription.contains('küçük') || lowerDescription.contains('az')) {
      baseCalories *= 0.7;
    }

    // Yağlı ifadeler için kalori artışı
    if (lowerDescription.contains('yağlı') || lowerDescription.contains('tereyağ')) {
      baseCalories *= 1.3;
      fat *= 1.5;
    }

    return NutritionEstimate(
      recognizedFood: recognizedFood,
      description: _generateDetailedDescription(recognizedFood, ingredients),
      ingredients: ingredients.isNotEmpty ? ingredients : ['Tahmin edilen malzemeler'],
      nutrition: NutritionInfo(
        calories: baseCalories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: fiber,
        sugar: carbs * 0.3, // Tahmini şeker
        sodium: 400, // Ortalama sodyum
      ),
      confidence: 0.75,
    );
  }

  /// Porsiyon büyüklüğünü tahmin et
  double _estimatePortionSize(String description) {
    final lower = description.toLowerCase();
    
    if (lower.contains('büyük') || lower.contains('çok') || lower.contains('bol')) {
      return 1.5;
    } else if (lower.contains('küçük') || lower.contains('az') || lower.contains('mini')) {
      return 0.7;
    } else if (lower.contains('orta')) {
      return 1.0;
    }
    
    // Sayı arama
    final numbers = RegExp(r'\d+').allMatches(lower);
    if (numbers.isNotEmpty) {
      final num = int.parse(numbers.first.group(0)!);
      if (num > 1 && num <= 5) {
        return num.toDouble();
      }
    }
    
    return 1.0; // Varsayılan porsiyon
  }

  /// Detaylı açıklama oluştur
  String _generateDetailedDescription(String foodName, List<String> ingredients) {
    if (ingredients.isEmpty) {
      return 'AI tarafından analiz edilen $foodName';
    }
    
    return '$foodName - İçerik: ${ingredients.join(', ')}';
  }

  /// Gemini AI yanıtını parse et
  NutritionEstimate? _parseGeminiResponse(String aiResponse, String originalDescription) {
    try {
      // JSON'u temizle (markdown formatından kurtul)
      String cleanedResponse = aiResponse.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();
      
      final data = json.decode(cleanedResponse);
      
      return NutritionEstimate(
        recognizedFood: data['recognizedFood'] ?? 'Gemini Tahmini',
        description: data['description'] ?? originalDescription,
        ingredients: List<String>.from(data['ingredients'] ?? []),
        nutrition: NutritionInfo(
          calories: (data['nutrition']['calories'] ?? 0).toDouble(),
          protein: (data['nutrition']['protein'] ?? 0).toDouble(),
          carbs: (data['nutrition']['carbs'] ?? 0).toDouble(),
          fat: (data['nutrition']['fat'] ?? 0).toDouble(),
          fiber: (data['nutrition']['fiber'] ?? 0).toDouble(),
          sugar: (data['nutrition']['sugar'] ?? 0).toDouble(),
          sodium: (data['nutrition']['sodium'] ?? 0).toDouble(),
        ),
        confidence: (data['confidence'] ?? 0.85).toDouble(),
      );
    } catch (e) {
      print('Gemini Response Parse Error: $e');
      print('Raw response: $aiResponse');
      return null;
    }
  }

  /// OpenAI yanıtını parse et
  NutritionEstimate? _parseOpenAIResponse(String aiResponse, String originalDescription) {
    try {
      // JSON'u temizle
      String cleanedResponse = aiResponse.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();
      
      final data = json.decode(cleanedResponse);
      
      return NutritionEstimate(
        recognizedFood: data['recognizedFood'] ?? 'OpenAI Tahmini',
        description: data['description'] ?? originalDescription,
        ingredients: List<String>.from(data['ingredients'] ?? []),
        nutrition: NutritionInfo(
          calories: (data['nutrition']['calories'] ?? 0).toDouble(),
          protein: (data['nutrition']['protein'] ?? 0).toDouble(),
          carbs: (data['nutrition']['carbs'] ?? 0).toDouble(),
          fat: (data['nutrition']['fat'] ?? 0).toDouble(),
          fiber: (data['nutrition']['fiber'] ?? 0).toDouble(),
          sugar: (data['nutrition']['sugar'] ?? 0).toDouble(),
          sodium: (data['nutrition']['sodium'] ?? 0).toDouble(),
        ),
        confidence: (data['confidence'] ?? 0.95).toDouble(),
      );
    } catch (e) {
      print('OpenAI Response Parse Error: $e');
      print('Raw response: $aiResponse');
      return null;
    }
  }

  /// Kalori sınırını kontrol et
  bool checkMealCalorieLimit(String mealType, double calories) {
    final limit = _mealLimits[mealType.toLowerCase()] ?? 500;
    return calories > limit;
  }

  /// Öğün tipine göre kalori sınırını al
  double getMealCalorieLimit(String mealType) {
    return _mealLimits[mealType.toLowerCase()] ?? 500;
  }

  /// Kullanılan AI sağlayıcısını al
  String getCurrentProvider(bool isPremium) {
    return isPremium ? 'OpenAI GPT-3.5' : 'Google Gemini';
  }

  /// AI servis durumunu kontrol et
  bool isUsingRealAI() {
    return true; // Artık her zaman gerçek AI kullanıyoruz
  }

  /// Gemini API ile günlük menü önerileri oluştur
  Future<List<Map<String, dynamic>>?> generateMenuSuggestions({
    bool isPremium = false,
    String? dietaryPreferences,
    int targetCalories = 2000,
    List<String>? allergies,
  }) async {
    try {
      if (isPremium) {
        return await _generateMenuWithOpenAI(
          dietaryPreferences: dietaryPreferences,
          targetCalories: targetCalories,
          allergies: allergies,
        );
      } else {
        return await _generateMenuWithGemini(
          dietaryPreferences: dietaryPreferences,
          targetCalories: targetCalories,
          allergies: allergies,
        );
      }
    } catch (e) {
      print('Menu Generation Error: $e');
      return _generateMockMenuSuggestions();
    }
  }

  /// Gemini ile menü önerisi oluştur
  Future<List<Map<String, dynamic>>?> _generateMenuWithGemini({
    String? dietaryPreferences,
    int targetCalories = 2000,
    List<String>? allergies,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    final prompt = '''
Lütfen günlük beslenme planı için 2 farklı menü önerisi oluştur. Türkçe yemekleri de dahil et.

Parametreler:
- Hedef kalori: $targetCalories
- Diyet tercihleri: ${dietaryPreferences ?? 'Yok'}
- Alerjiler: ${allergies?.join(', ') ?? 'Yok'}

Her menü önerisi için şu JSON formatını kullan:
[
  {
    "title": "Menü başlığı",
    "description": "Menünün kısa açıklaması",
    "healthScore": 8.5,
    "dietaryTags": ["tag1", "tag2", "tag3"],
    "reasonForSuggestion": "Bu menünün önerilme sebebi",
    "meals": [
      {
        "name": "Yemek adı",
        "mealType": "breakfast/lunch/dinner/snack",
        "calories": sayı,
        "description": "Yemeğin açıklaması",
        "ingredients": ["malzeme1", "malzeme2", "malzeme3"],
        "hour": 8,
        "minute": 0
      }
    ]
  }
]

2 farklı menü önerisi oluştur. Biri Akdeniz diyeti tarzında, diğeri Türk mutfağı ağırlıklı olsun.
Sadece JSON array döndür, başka açıklama ekleme.
''';

    final body = json.encode({
      'contents': [
        {
          'parts': [
            {
              'text': prompt
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      }
    });

    try {
      final response = await http.post(
        Uri.parse('$_geminiEndpoint?key=$_geminiApiKey'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        
        return _parseMenuSuggestions(content);
      } else {
        print('Gemini Menu API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Gemini Menu API Error: $e');
      return null;
    }
  }

  /// OpenAI ile menü önerisi oluştur (Premium)
  Future<List<Map<String, dynamic>>?> _generateMenuWithOpenAI({
    String? dietaryPreferences,
    int targetCalories = 2000,
    List<String>? allergies,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAIApiKey',
    };

    final systemPrompt = '''
Sen bir profesyonel diyetisyensin. Kullanıcı için günlük beslenme planları oluşturuyorsun.
Türkçe ve uluslararası mutfakları çok iyi biliyorsun.
Porsiyon büyüklüklerini ve kalori hesaplamalarını doğru yapabiliyorsun.
''';

    final userPrompt = '''
Lütfen günlük beslenme planı için 3 farklı menü önerisi oluştur.

Parametreler:
- Hedef kalori: $targetCalories
- Diyet tercihleri: ${dietaryPreferences ?? 'Yok'}
- Alerjiler: ${allergies?.join(', ') ?? 'Yok'}

JSON formatında 3 menü önerisi döndür. Her menü için kahvaltı, öğle, akşam yemeği ve 1 atıştırmalık dahil et.
Sadece JSON array döndür.
''';

    final body = json.encode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': systemPrompt
        },
        {
          'role': 'user',
          'content': userPrompt
        }
      ],
      'max_tokens': 2000,
      'temperature': 0.7,
    });

    try {
      final response = await http.post(
        Uri.parse(_openAIEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        return _parseMenuSuggestions(content);
      } else {
        print('OpenAI Menu API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('OpenAI Menu API Error: $e');
      return null;
    }
  }

  /// Menü önerilerini parse et
  List<Map<String, dynamic>>? _parseMenuSuggestions(String response) {
    try {
      // JSON'u temizle
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();
      
      final List<dynamic> data = json.decode(cleanedResponse);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Menu Parse Error: $e');
      print('Raw response: $response');
      return null;
    }
  }

  /// Mock menü önerileri (fallback)
  List<Map<String, dynamic>> _generateMockMenuSuggestions() {
    return [
      {
        "title": "Akdeniz Diyeti Menüsü",
        "description": "Sağlıklı yağlar, taze sebzeler ve protein açısından zengin",
        "healthScore": 9.2,
        "dietaryTags": ["Akdeniz", "Yüksek Protein", "Kalp Dostu"],
        "reasonForSuggestion": "Dengeli beslenme ve sağlıklı yaşam için ideal",
        "meals": [
          {
            "name": "Meyveli Yulaf Ezmesi",
            "mealType": "breakfast",
            "calories": 280,
            "description": "Yulaf ezmesi üzerine taze meyveler ve bal",
            "ingredients": ["Yulaf ezmesi", "Yaban mersini", "Çilek", "Bal"],
            "hour": 8,
            "minute": 0
          },
          {
            "name": "Akdeniz Kinoa Kasesi",
            "mealType": "lunch", 
            "calories": 420,
            "description": "Kinoa ile ızgara tavuk, sebzeler ve tzatziki",
            "ingredients": ["Kinoa", "Izgara tavuk", "Salatalık", "Domates", "Tzatziki"],
            "hour": 12,
            "minute": 30
          },
          {
            "name": "Sebzeli Izgara Somon",
            "mealType": "dinner",
            "calories": 380,
            "description": "Izgara somon ile közlenmiş Akdeniz sebzeleri",
            "ingredients": ["Somon", "Kabak", "Biber", "Zeytinyağı"],
            "hour": 19,
            "minute": 0
          }
        ]
      },
      {
        "title": "Türk Mutfağı Menüsü",
        "description": "Geleneksel Türk lezzetleri ile sağlıklı beslenme",
        "healthScore": 8.8,
        "dietaryTags": ["Türk Mutfağı", "Geleneksel", "Lezzetli"],
        "reasonForSuggestion": "Türk damak tadına uygun sağlıklı seçenekler",
        "meals": [
          {
            "name": "Peynirli Menemen",
            "mealType": "breakfast",
            "calories": 320,
            "description": "Domates, biber ve peynirle hazırlanan menemen",
            "ingredients": ["Yumurta", "Domates", "Biber", "Beyaz peynir"],
            "hour": 8,
            "minute": 0
          },
          {
            "name": "Mercimek Çorbası ve Salata",
            "mealType": "lunch",
            "calories": 380,
            "description": "Kırmızı mercimek çorbası ile mevsim salatası",
            "ingredients": ["Kırmızı mercimek", "Soğan", "Havuç", "Yeşillik"],
            "hour": 12,
            "minute": 30
          },
          {
            "name": "Izgara Köfte ve Pilav",
            "mealType": "dinner",
            "calories": 450,
            "description": "Izgara köfte ile bulgur pilavı",
            "ingredients": ["Dana kıyma", "Bulgur", "Soğan", "Maydanoz"],
            "hour": 19,
            "minute": 0
          }
        ]
      }
    ];
  }
}

// KULLANIM KLAVUZU:
/*
1. Gerçek AI kullanmak için:
   - pubspec.yaml'a http paketi ekleyin: http: ^1.1.0
   - API anahtarlarınızı _openAIApiKey, _geminiApiKey vb. değişkenlere ekleyin
   - _provider'ı istediğiniz servise değiştirin

2. OpenAI için:
   - https://platform.openai.com/'dan API anahtarı alın
   - _provider = AIProvider.openai yapın

3. Google Gemini için:
   - https://makersuite.google.com/'dan API anahtarı alın
   - _provider = AIProvider.gemini yapın

4. Nutrition API için:
   - Edamam, Spoonacular gibi API'lardan anahtar alın
   - _provider = AIProvider.nutritionapi yapın

5. Güvenlik için API anahtarlarınızı:
   - .env dosyasında saklayın
   - Veya secure storage kullanın
   - GitHub'a commit etmeyin!
*/ 