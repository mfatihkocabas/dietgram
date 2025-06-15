import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../models/user_profile.dart';
import '../services/premium_service.dart';
import 'edit_profile_screen.dart';
import 'goals_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _userProfile = UserProfile(
        id: prefs.getString('user_id') ?? 'user_1',
        name: prefs.getString('user_name') ?? 'John Doe',
        email: prefs.getString('user_email') ?? 'john@example.com',
        age: prefs.getInt('user_age') ?? 25,
        weight: prefs.getDouble('user_weight') ?? 70.0,
        height: prefs.getDouble('user_height') ?? 175.0,
        gender: prefs.getString('user_gender') ?? 'male',
        activityLevel: prefs.getString('user_activity_level') ?? 'moderate',
        goal: prefs.getString('user_goal') ?? 'maintain_weight',
        dailyCalorieGoal: prefs.getInt('user_daily_calorie_goal') ?? 2000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          _userProfile?.name.isNotEmpty == true 
                              ? _userProfile!.name[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.epilogue(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Info
                  Text(
                    _userProfile?.name ?? 'Kullanıcı',
                    style: GoogleFonts.epilogue(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    _userProfile?.email ?? 'email@example.com',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  if (_userProfile != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('BMI', _userProfile!.bmi.toStringAsFixed(1)),
                        _buildStatItem('Hedef', '${_userProfile!.dailyCalorieGoal} kal'),
                        _buildStatItem('Yaş', '${_userProfile!.age}'),
                      ],
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Profile Options
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Profili Düzenle',
                    subtitle: 'Kişisel bilgilerinizi güncelleyin',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(userProfile: _userProfile!),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _userProfile = result;
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.track_changes,
                    title: 'Hedefler ve Amaçlar',
                    subtitle: 'Sağlık ve fitness hedeflerinizi belirleyin',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoalsScreen(userProfile: _userProfile!),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _userProfile = result;
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Bildirimler',
                    subtitle: 'Bildirim tercihlerinizi yönetin',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Bildirim ayarları yakında eklenecek!',
                            style: GoogleFonts.epilogue(),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Yardım ve Destek',
                    subtitle: 'Yardım alın ve destek ekibiyle iletişime geçin',
                    onTap: () => _showHelpAndSupport(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Premium Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: _buildProfileOption(
                icon: Icons.star_outline,
                title: 'Premium\'a Geç',
                subtitle: 'Tüm özelliklerin kilidini açın',
                onTap: () {
                  Navigator.pushNamed(context, '/premium');
                },
                showArrow: true,
                iconColor: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // About Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildProfileOption(
                icon: Icons.info_outline,
                title: 'Hakkında',
                subtitle: 'Uygulama sürümü ve bilgileri',
                onTap: () => _showAboutDialog(),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.epilogue(
            fontSize: 12,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.epilogue(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textMedium,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.textMedium.withOpacity(0.1),
      indent: 68,
    );
  }

  void _showHelpAndSupport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Yardım ve Destek',
                    style: GoogleFonts.epilogue(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildHelpOption(
                    icon: Icons.email_outlined,
                    title: 'E-posta Gönder',
                    subtitle: 'destek@dietgram.com',
                    onTap: () => _sendEmail(),
                  ),
                  const SizedBox(height: 16),
                  _buildHelpOption(
                    icon: Icons.bug_report_outlined,
                    title: 'Hata Bildir',
                    subtitle: 'Karşılaştığınız sorunları bildirin',
                    onTap: () => _reportBug(),
                  ),
                  const SizedBox(height: 16),
                  _buildHelpOption(
                    icon: Icons.lightbulb_outline,
                    title: 'Öneride Bulun',
                    subtitle: 'Uygulamamızı geliştirmemize yardımcı olun',
                    onTap: () => _sendSuggestion(),
                  ),
                  const SizedBox(height: 16),
                  _buildHelpOption(
                    icon: Icons.star_outline,
                    title: 'Uygulamayı Değerlendir',
                    subtitle: 'App Store\'da değerlendirin',
                    onTap: () => _rateApp(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.epilogue(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textMedium,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Dietgram Hakkında',
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dietgram v1.0.0',
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'AI destekli kişisel beslenme asistanınız.\n\nSağlıklı yaşam için ❤️ ile geliştirildi.',
              style: GoogleFonts.epilogue(
                fontSize: 14,
                color: AppColors.textMedium,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Kapat',
              style: GoogleFonts.epilogue(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'destek@dietgram.com',
      query: 'subject=Dietgram Destek Talebi&body=Merhaba Dietgram ekibi,\n\n',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'E-posta uygulaması açılamadı. Lütfen destek@dietgram.com adresine manuel olarak e-posta gönderin.',
            style: GoogleFonts.epilogue(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _reportBug() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'destek@dietgram.com',
      query: 'subject=Dietgram Hata Bildirimi&body=Hata Detayları:\n\n1. Ne yapmaya çalışıyordunuz?\n\n2. Ne oldu?\n\n3. Beklediğiniz sonuç neydi?\n\n',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _sendSuggestion() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'destek@dietgram.com',
      query: 'subject=Dietgram Önerisi&body=Önerim:\n\n',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _rateApp() async {
    // App Store URL (iOS için)
    const String appStoreUrl = 'https://apps.apple.com/app/dietgram';
    
    if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
      await launchUrl(Uri.parse(appStoreUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'App Store açılamadı.',
            style: GoogleFonts.epilogue(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
} 