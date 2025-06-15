import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_menu_suggestion.dart';
import '../models/meal.dart';

class AIMenuService {
  static const String _geminiApiKey = 'AIzaSyDyCppKyhdMzjkiZCEXZX2Fg7brUZatJeE';
  static const String _geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String _openAIApiKey = 'your-openai-api-key-here';
  static const String _openAIEndpoint = 'https://api.openai.com/v1/chat/completions';

  DateTime? _lastRequestTime;
  static const int _cooldownSeconds = 15;

  /// Cooldown kontrolü
  bool canMakeRequest() {
    if (_lastRequestTime == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastRequestTime!).inSeconds;
    return difference >= _cooldownSeconds;
  }

  /// Kalan cooldown süresi
  int getRemainingCooldown() {
    if (_lastRequestTime == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(_lastRequestTime!).inSeconds;
    final remaining = _cooldownSeconds - difference;
    return remaining > 0 ? remaining : 0;
  }

  /// AI ile menü önerileri oluştur
  Future<List<AIMenuSuggestion>?> generateMenuSuggestions({
    bool isPremium = false,
    String? dietaryPreferences,
    int targetCalories = 2000,
    List<String>? allergies,
  }) async {
    if (!canMakeRequest()) {
      throw Exception('Lütfen ${getRemainingCooldown()} saniye bekleyin');
    }

    _lastRequestTime = DateTime.now();

    try {
      List<Map<String, dynamic>>? suggestions;
      
      if (isPremium) {
        suggestions = await _generateWithOpenAI(
          dietaryPreferences: dietaryPreferences,
          targetCalories: targetCalories,
          allergies: allergies,
        );
      } else {
        suggestions = await _generateWithGemini(
          dietaryPreferences: dietaryPreferences,
          targetCalories: targetCalories,
          allergies: allergies,
        );
      }

      if (suggestions != null && suggestions.isNotEmpty) {
        // AI'dan başarılı cevap geldi - sadece 1 menü döndür
        final aiSuggestions = _convertToAIMenuSuggestions(suggestions);
        return aiSuggestions.take(1).toList();
      } else {
        // AI başarısız - 2 fallback menü döndür
        return _generateFallbackSuggestions();
      }
    } catch (e) {
      print('AI Menu Service Error: $e');
      return _generateFallbackSuggestions();
    }
  }

  /// Gemini ile menü önerisi oluştur
  Future<List<Map<String, dynamic>>?> _generateWithGemini({
    String? dietaryPreferences,
    int targetCalories = 2000,
    List<String>? allergies,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    final prompt = '''
$targetCalories kalori günlük menü. JSON:
[{"title":"X Menüsü","description":"kısa","healthScore":8.5,"dietaryTags":["tag1","tag2"],"reasonForSuggestion":"sebep","meals":[{"name":"kahvaltı","mealType":"breakfast","calories":300,"description":"açıklama","ingredients":["a","b"],"hour":8,"minute":0},{"name":"öğle","mealType":"lunch","calories":450,"description":"açıklama","ingredients":["c","d"],"hour":12,"minute":30},{"name":"akşam","mealType":"dinner","calories":400,"description":"açıklama","ingredients":["e","f"],"hour":19,"minute":0}]}]
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
        'topK': 20,
        'topP': 0.9,
        'maxOutputTokens': 800,
      }
    });

    try {
      print('🚀 Gemini API Request URL: $_geminiEndpoint?key=${_geminiApiKey.substring(0, 10)}...');
      print('📤 Request Body: ${body.substring(0, 200)}...');
      
      final response = await http.post(
        Uri.parse('$_geminiEndpoint?key=$_geminiApiKey'),
        headers: headers,
        body: body,
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body.substring(0, 500)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          print('✅ AI Content received: ${content.substring(0, 200)}...');
          
          final parsed = _parseMenuResponse(content);
          if (parsed != null) {
            print('✅ Successfully parsed ${parsed.length} menu(s) from AI');
          }
          return parsed;
        } else {
          print('❌ No candidates in response');
          return null;
        }
      } else {
        print('❌ Gemini Menu API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Gemini Menu API Exception: $e');
      return null;
    }
  }

  /// OpenAI ile menü önerisi oluştur (Premium)
  Future<List<Map<String, dynamic>>?> _generateWithOpenAI({
    String? dietaryPreferences,
    int targetCalories = 2000,
    List<String>? allergies,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAIApiKey',
    };

    final systemPrompt = 'Diyetisyen. JSON menü oluştur.';

    final userPrompt = '$targetCalories kalori menü. JSON: [{"title":"","description":"","healthScore":8,"dietaryTags":[],"reasonForSuggestion":"","meals":[{"name":"","mealType":"breakfast","calories":300,"description":"","ingredients":[],"hour":8,"minute":0},{"name":"","mealType":"lunch","calories":450,"description":"","ingredients":[],"hour":12,"minute":30},{"name":"","mealType":"dinner","calories":400,"description":"","ingredients":[],"hour":19,"minute":0}]}]';

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
      'max_tokens': 600,
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
        
        return _parseMenuResponse(content);
      } else {
        print('OpenAI Menu API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('OpenAI Menu API Error: $e');
      return null;
    }
  }

  /// Menü yanıtını parse et
  List<Map<String, dynamic>>? _parseMenuResponse(String response) {
    try {
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

  /// Map'leri AIMenuSuggestion'a çevir
  List<AIMenuSuggestion> _convertToAIMenuSuggestions(List<Map<String, dynamic>> suggestions) {
    return suggestions.map((suggestion) {
      final meals = (suggestion['meals'] as List<dynamic>? ?? []).map((mealData) {
        return Meal(
          id: DateTime.now().millisecondsSinceEpoch.toString() + 
               (mealData['name'] ?? '').hashCode.toString(),
          name: mealData['name'] ?? 'Bilinmeyen Yemek',
          mealType: mealData['mealType'] ?? 'snack',
          calories: (mealData['calories'] ?? 0).toDouble(),
          date: DateTime.now().add(Duration(
            hours: mealData['hour'] ?? 12,
            minutes: mealData['minute'] ?? 0,
          )),
          createdAt: DateTime.now(),
          description: mealData['description'] ?? '',
          ingredients: List<String>.from(mealData['ingredients'] ?? []),
        );
      }).toList();

      return AIMenuSuggestion.create(
        title: suggestion['title'] ?? 'AI Menü Önerisi',
        description: suggestion['description'] ?? 'AI tarafından oluşturulan menü',
        meals: meals,
        dietaryTags: List<String>.from(suggestion['dietaryTags'] ?? []),
        healthScore: (suggestion['healthScore'] ?? 8.0).toDouble(),
        reasonForSuggestion: suggestion['reasonForSuggestion'] ?? 
                            'AI tarafından önerilen sağlıklı menü',
      );
    }).toList();
  }

  /// Fallback menü önerileri
  List<AIMenuSuggestion> _generateFallbackSuggestions() {
    final suggestions = [
      // Akdeniz Diyeti
      AIMenuSuggestion.create(
        title: "Akdeniz Diyeti Menüsü",
        description: "Sağlıklı yağlar, taze sebzeler ve protein açısından zengin",
        meals: [
          Meal(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: "Avokadolu Tam Buğday Ekmeği",
            mealType: "breakfast",
            calories: 320,
            date: DateTime.now().add(const Duration(hours: 8)),
            createdAt: DateTime.now(),
            description: "Ezilmiş avokado, domates ve feta peyniri ile",
            ingredients: ["Tam buğday ekmeği", "Avokado", "Domates", "Feta peyniri", "Zeytinyağı"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            name: "Akdeniz Salatası",
            mealType: "lunch",
            calories: 450,
            date: DateTime.now().add(const Duration(hours: 12, minutes: 30)),
            createdAt: DateTime.now(),
            description: "Izgara tavuk göğsü ile renkli sebze salatası",
            ingredients: ["Izgara tavuk", "Salatalık", "Domates", "Zeytin", "Feta", "Zeytinyağı"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
            name: "Fırında Levrek",
            mealType: "dinner",
            calories: 380,
            date: DateTime.now().add(const Duration(hours: 19)),
            createdAt: DateTime.now(),
            description: "Sebzeli fırında levrek balığı",
            ingredients: ["Levrek", "Kabak", "Patlıcan", "Biber", "Zeytinyağı"],
          ),
        ],
        dietaryTags: ["Akdeniz", "Yüksek Protein", "Kalp Dostu"],
        healthScore: 9.2,
        reasonForSuggestion: "Kalp sağlığı için ideal, omega-3 açısından zengin",
      ),
      
      // Türk Mutfağı
      AIMenuSuggestion.create(
        title: "Geleneksel Türk Menüsü",
        description: "Sağlıklı Türk mutfağı lezzetleri",
        meals: [
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
            name: "Çılbır (Yoğurtlu Yumurta)",
            mealType: "breakfast",
            calories: 290,
            date: DateTime.now().add(const Duration(hours: 8)),
            createdAt: DateTime.now(),
            description: "Poşe yumurta, yoğurt ve tereyağlı sos",
            ingredients: ["Yumurta", "Yoğurt", "Tereyağı", "Kırmızı biber", "Dereotu"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
            name: "Ezogelin Çorbası ve Salata",
            mealType: "lunch",
            calories: 350,
            date: DateTime.now().add(const Duration(hours: 12, minutes: 30)),
            createdAt: DateTime.now(),
            description: "Ezogelin çorbası ile çoban salatası",
            ingredients: ["Kırmızı mercimek", "Bulgur", "Domates", "Salatalık", "Soğan"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 5).toString(),
            name: "Fırında Tavuk Göğsü",
            mealType: "dinner",
            calories: 420,
            date: DateTime.now().add(const Duration(hours: 19)),
            createdAt: DateTime.now(),
            description: "Sebzeli fırında tavuk göğsü ve pilav",
            ingredients: ["Tavuk göğsü", "Havuç", "Patates", "Pirinç", "Baharat"],
          ),
        ],
        dietaryTags: ["Türk Mutfağı", "Geleneksel", "Protein"],
        healthScore: 8.5,
        reasonForSuggestion: "Türk damak tadına uygun, besleyici öğünler",
      ),

      // Vejeteryan
      AIMenuSuggestion.create(
        title: "Vejeteryan Beslenme Planı",
        description: "Bitki bazlı protein kaynakları ile dengeli beslenme",
        meals: [
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 6).toString(),
            name: "Chia Pudingi",
            mealType: "breakfast",
            calories: 280,
            date: DateTime.now().add(const Duration(hours: 8)),
            createdAt: DateTime.now(),
            description: "Chia tohumu, badem sütü ve meyveler",
            ingredients: ["Chia tohumu", "Badem sütü", "Muz", "Yaban mersini", "Bal"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 7).toString(),
            name: "Nohut Salatası",
            mealType: "lunch",
            calories: 400,
            date: DateTime.now().add(const Duration(hours: 12, minutes: 30)),
            createdAt: DateTime.now(),
            description: "Protein açısından zengin nohut salatası",
            ingredients: ["Nohut", "Roka", "Domates", "Avokado", "Limon", "Zeytinyağı"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 8).toString(),
            name: "Sebzeli Makarna",
            mealType: "dinner",
            calories: 380,
            date: DateTime.now().add(const Duration(hours: 19)),
            createdAt: DateTime.now(),
            description: "Tam buğday makarna ile mevsim sebzeleri",
            ingredients: ["Tam buğday makarna", "Kabak", "Patlıcan", "Domates", "Fesleğen"],
          ),
        ],
        dietaryTags: ["Vejeteryan", "Yüksek Lif", "Bitki Bazlı"],
        healthScore: 8.8,
        reasonForSuggestion: "Bitki bazlı protein ve lif açısından zengin",
      ),

      // Fitness Menüsü
      AIMenuSuggestion.create(
        title: "Fitness & Protein Menüsü",
        description: "Yüksek protein, düşük karbonhidrat beslenme",
        meals: [
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 9).toString(),
            name: "Protein Omlet",
            mealType: "breakfast",
            calories: 350,
            date: DateTime.now().add(const Duration(hours: 8)),
            createdAt: DateTime.now(),
            description: "3 yumurtalı omlet, ispanak ve peynir",
            ingredients: ["Yumurta", "İspanak", "Beyaz peynir", "Domates", "Biber"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 10).toString(),
            name: "Izgara Somon Salata",
            mealType: "lunch",
            calories: 480,
            date: DateTime.now().add(const Duration(hours: 12, minutes: 30)),
            createdAt: DateTime.now(),
            description: "Omega-3 açısından zengin somon salatası",
            ingredients: ["Somon", "Kinoa", "Brokoli", "Avokado", "Limon"],
          ),
          Meal(
            id: (DateTime.now().millisecondsSinceEpoch + 11).toString(),
            name: "Izgara Tavuk ve Sebze",
            mealType: "dinner",
            calories: 420,
            date: DateTime.now().add(const Duration(hours: 19)),
            createdAt: DateTime.now(),
            description: "Yüksek protein tavuk göğsü ve buharda sebze",
            ingredients: ["Tavuk göğsü", "Brokoli", "Havuç", "Kabak", "Baharatlı sos"],
          ),
        ],
        dietaryTags: ["Yüksek Protein", "Fitness", "Düşük Karbonhidrat"],
        healthScore: 9.0,
        reasonForSuggestion: "Kas gelişimi ve kilo kontrolü için ideal",
      ),
    ];

    // Rastgele 2 menü seç
    suggestions.shuffle();
    return suggestions.take(2).toList();
  }
} 