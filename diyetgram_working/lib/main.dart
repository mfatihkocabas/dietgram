import 'package:flutter/material.dart';

void main() {
  runApp(const DiyetgramApp());
}

class DiyetgramApp extends StatelessWidget {
  const DiyetgramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diyetgram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF21DF26),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// User Profile Model
class UserProfile {
  String name;
  int age;
  double weight;
  double height;
  String activityLevel;
  List<String> healthConditions;
  List<String> allergies;
  String goal;
  String avatarPath;

  UserProfile({
    this.name = '',
    this.age = 0,
    this.weight = 0.0,
    this.height = 0.0,
    this.activityLevel = 'Moderate',
    this.healthConditions = const [],
    this.allergies = const [],
    this.goal = 'Maintain Weight',
    this.avatarPath = '',
  });

  double get bmi => weight / ((height / 100) * (height / 100));
  
  int get dailyCalorieGoal {
    // Harris-Benedict equation with activity factor
    double bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5; // for male (simplified)
    Map<String, double> activityMultiplier = {
      'Sedentary': 1.2,
      'Light': 1.375,
      'Moderate': 1.55,
      'Active': 1.725,
      'Very Active': 1.9,
    };
    return (bmr * (activityMultiplier[activityLevel] ?? 1.55)).round();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await _logoController.forward();
    await _textController.forward();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF21DF26),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Color(0xFF21DF26),
                      size: 60,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            AnimatedBuilder(
              animation: _textOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: Column(
                    children: [
                      const Text(
                        'Diyetgram',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AI-Powered Diet Planning',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 60),
            
            AnimatedBuilder(
              animation: _textOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value * 0.7,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF21DF26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Diyetgram AI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121712),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Kişiselleştirilmiş AI Diyet Asistanınız',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6C876C),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                '• Sağlık durumunuza özel menüler\n• Kalori hesaplama\n• Kişisel diyet programı\n• Akıllı beslenme önerileri',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C876C),
                ),
              ),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF21DF26),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  child: const Text(
                    'Başlayalım',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> meals = [];
  UserProfile userProfile = UserProfile();

  void addMeal(String type, String name, int calories) {
    setState(() {
      meals.add({
        'type': type,
        'name': name,
        'calories': calories,
        'time': DateTime.now(),
      });
    });
  }

  int get totalCalories => meals.fold(0, (sum, meal) => sum + meal['calories'] as int);
  int get remainingCalories => (userProfile.dailyCalorieGoal - totalCalories).clamp(0, double.infinity).toInt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Diyetgram AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF121712),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF21DF26)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userProfile: userProfile,
                    onProfileUpdated: (profile) {
                      setState(() {
                        userProfile = profile;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calorie Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF21DF26), Color(0xFF1BC920)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF21DF26).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Günlük Kalori',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$totalCalories / ${userProfile.dailyCalorieGoal}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Kalan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$remainingCalories kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (totalCalories / userProfile.dailyCalorieGoal).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'AI Menü',
                    Icons.psychology,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AIMenuScreen(userProfile: userProfile),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'Yemek Ekle',
                    Icons.add_circle_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMealScreen(onMealAdded: addMeal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Bugünkü Yemekler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121712),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: meals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz yemek eklenmedi',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AI menü önerisi alın veya manuel ekleyin',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF21DF26),
                              child: Text(
                                meal['type'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              meal['name'],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(meal['type']),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF21DF26).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${meal['calories']} kcal',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF21DF26),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF21DF26).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF21DF26),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF121712),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMealScreen extends StatelessWidget {
  final Function(String, String, int) onMealAdded;

  const AddMealScreen({super.key, required this.onMealAdded});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMealOption(context, 'Breakfast', 'Start your day right', Icons.wb_sunny, 350),
          _buildMealOption(context, 'Lunch', 'Midday fuel', Icons.lunch_dining, 450),
          _buildMealOption(context, 'Dinner', 'Evening satisfaction', Icons.dinner_dining, 400),
          _buildMealOption(context, 'Snack', 'Quick bite', Icons.cookie, 150),
        ],
      ),
    );
  }

  Widget _buildMealOption(BuildContext context, String type, String description, IconData icon, int calories) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF21DF26),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          type,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          onMealAdded(type, 'Sample $type', calories);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$type added successfully!'),
              backgroundColor: const Color(0xFF21DF26),
            ),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late UserProfile profile;

  @override
  void initState() {
    super.initState();
    profile = UserProfile(
      name: widget.userProfile.name,
      age: widget.userProfile.age,
      weight: widget.userProfile.weight,
      height: widget.userProfile.height,
      activityLevel: widget.userProfile.activityLevel,
      healthConditions: List.from(widget.userProfile.healthConditions),
      allergies: List.from(widget.userProfile.allergies),
      goal: widget.userProfile.goal,
    );
    
    nameController = TextEditingController(text: profile.name);
    ageController = TextEditingController(text: profile.age.toString());
    weightController = TextEditingController(text: profile.weight.toString());
    heightController = TextEditingController(text: profile.height.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              profile.name = nameController.text;
              profile.age = int.tryParse(ageController.text) ?? 0;
              profile.weight = double.tryParse(weightController.text) ?? 0.0;
              profile.height = double.tryParse(heightController.text) ?? 0.0;
              widget.onProfileUpdated(profile);
              Navigator.pop(context);
            },
            child: const Text('Kaydet', style: TextStyle(color: Color(0xFF21DF26))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF21DF26),
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF21DF26),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Basic Info
            _buildTextField('İsim', nameController),
            _buildTextField('Yaş', ageController, isNumber: true),
            _buildTextField('Kilo (kg)', weightController, isNumber: true),
            _buildTextField('Boy (cm)', heightController, isNumber: true),
            
            const SizedBox(height: 20),
            
            // Activity Level
            _buildDropdown(
              'Aktivite Seviyesi',
              profile.activityLevel,
              ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'],
              (value) => setState(() => profile.activityLevel = value!),
            ),
            
            // Goal
            _buildDropdown(
              'Hedef',
              profile.goal,
              ['Lose Weight', 'Maintain Weight', 'Gain Weight'],
              (value) => setState(() => profile.goal = value!),
            ),
            
            const SizedBox(height: 20),
            
            // Health Conditions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sağlık Durumu', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildHealthChip('Diyabet', 'Diyabet'),
                        _buildHealthChip('Hipertansiyon', 'Hipertansiyon'),
                        _buildHealthChip('Kalp Hastalığı', 'Kalp Hastalığı'),
                        _buildHealthChip('Kolesterol', 'Kolesterol'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stats Card
            if (profile.weight > 0 && profile.height > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('İstatistikler', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('BMI', profile.bmi.toStringAsFixed(1)),
                          _buildStatItem('Günlük Kalori', '${profile.dailyCalorieGoal}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFFF0F5F0),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFFF0F5F0),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildHealthChip(String label, String condition) {
    bool isSelected = profile.healthConditions.contains(condition);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            profile.healthConditions.add(condition);
          } else {
            profile.healthConditions.remove(condition);
          }
        });
      },
      selectedColor: const Color(0xFF21DF26).withOpacity(0.3),
      checkmarkColor: const Color(0xFF21DF26),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class AIMenuScreen extends StatefulWidget {
  final UserProfile userProfile;

  const AIMenuScreen({super.key, required this.userProfile});

  @override
  State<AIMenuScreen> createState() => _AIMenuScreenState();
}

class _AIMenuScreenState extends State<AIMenuScreen> {
  bool isGenerating = false;
  List<Map<String, dynamic>> aiMenus = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Menü Önerisi'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kişisel Bilgiler', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Hedef: ${widget.userProfile.goal}'),
                    Text('Aktivite: ${widget.userProfile.activityLevel}'),
                    if (widget.userProfile.healthConditions.isNotEmpty)
                      Text('Sağlık: ${widget.userProfile.healthConditions.join(", ")}'),
                    Text('Günlük Kalori: ${widget.userProfile.dailyCalorieGoal} kcal'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21DF26),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isGenerating ? null : _generateAIMenu,
                icon: isGenerating 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.psychology),
                label: Text(isGenerating ? 'AI Menü Oluşturuluyor...' : 'AI Menü Oluştur'),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // AI Generated Menus
            Expanded(
              child: aiMenus.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.psychology, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('AI menü önerisi almak için butona basın'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: aiMenus.length,
                      itemBuilder: (context, index) {
                        final menu = aiMenus[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF21DF26),
                              child: Icon(Icons.restaurant, color: Colors.white),
                            ),
                            title: Text(menu['name']),
                            subtitle: Text('${menu['calories']} kcal • ${menu['description']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle, color: Color(0xFF21DF26)),
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${menu['name']} menüye eklendi!'),
                                    backgroundColor: const Color(0xFF21DF26),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateAIMenu() async {
    setState(() {
      isGenerating = true;
    });

    // Simulate AI generation delay
    await Future.delayed(const Duration(seconds: 2));

    // Sample AI-generated menus based on user profile
    List<Map<String, dynamic>> generatedMenus = [
      {
        'name': 'Protein Yumurta Tabağı',
        'calories': 320,
        'description': 'Omlet, avokado, tam buğday ekmeği',
      },
      {
        'name': 'Akdeniz Salatası',
        'calories': 280,
        'description': 'Zeytinyağlı, protein açısından zengin',
      },
      {
        'name': 'Sağlıklı Tavuk Izgara',
        'calories': 450,
        'description': 'Az yağlı, yüksek protein',
      },
    ];

    // Customize based on health conditions
    if (widget.userProfile.healthConditions.contains('Diyabet')) {
      generatedMenus.add({
        'name': 'Düşük Karbonhidrat Bowl',
        'calories': 300,
        'description': 'Diyabet dostu, kontrollü karbonhidrat',
      });
    }

    setState(() {
      aiMenus = generatedMenus;
      isGenerating = false;
    });
  }
}
