import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/premium_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<PremiumService>(
        builder: (context, premiumService, child) {
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'DietGram Premium',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Icon(
                          Icons.diamond,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  if (premiumService.isPremium)
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PREMIUM',
                        style: GoogleFonts.epilogue(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Status
                          _buildCurrentStatus(premiumService),
                          
                          const SizedBox(height: 30),
                          
                          // Features
                          _buildFeaturesSection(premiumService),
                          
                          const SizedBox(height: 30),
                          
                          // Usage Stats (for free users)
                          if (premiumService.isFree) ...[
                            _buildUsageStats(premiumService),
                            const SizedBox(height: 30),
                          ],
                          
                          // Pricing Plans
                          if (premiumService.isFree) _buildPricingPlans(premiumService),
                          
                          // Premium Benefits
                          if (premiumService.isPremium) _buildPremiumBenefits(),
                          
                          const SizedBox(height: 30),
                          
                          // Action Buttons
                          _buildActionButtons(premiumService),
                          
                          const SizedBox(height: 20),
                          
                          // Footer
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStatus(PremiumService premiumService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: premiumService.isPremium
              ? [Colors.amber.withOpacity(0.1), Colors.orange.withOpacity(0.1)]
              : [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: premiumService.isPremium ? Colors.amber : AppColors.primary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: premiumService.isPremium ? Colors.amber : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              premiumService.isPremium ? Icons.diamond : Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  premiumService.isPremium ? 'Premium Üye' : 'Ücretsiz Üye',
                  style: GoogleFonts.epilogue(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  premiumService.isPremium 
                      ? 'Tüm özelliklerden sınırsız yararlanabilirsiniz'
                      : 'Sınırlı özelliklerle deneyim yaşıyorsunuz',
                  style: GoogleFonts.epilogue(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(PremiumService premiumService) {
    final features = [
      {
        'icon': Icons.restaurant_menu,
        'title': 'Özel Yemek Ekleme',
        'description': 'AI destekli kalori hesaplama',
        'free': '${premiumService.remainingCustomMeals}/gün',
        'premium': 'Sınırsız',
      },
      {
        'icon': Icons.psychology,
        'title': 'AI Analizi',
        'description': 'Akıllı beslenme önerileri',
        'free': '${premiumService.remainingAIAnalysis}/hafta',
        'premium': 'Sınırsız',
      },
      {
        'icon': Icons.block,
        'title': 'Reklamsız Deneyim',
        'description': 'Hiç reklam görmeden uygulamayı kullanın',
        'free': 'Reklamlar var',
        'premium': 'Reklamsız',
      },
      {
        'icon': Icons.analytics,
        'title': 'Gelişmiş Raporlar',
        'description': 'Detaylı beslenme analizi',
        'free': 'Temel raporlar',
        'premium': 'Gelişmiş raporlar',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özellik Karşılaştırması',
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureItem(feature, premiumService.isPremium)),
      ],
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> feature, bool isPremium) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature['icon'],
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'],
                  style: GoogleFonts.epilogue(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  feature['description'],
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPremium ? Colors.amber.withOpacity(0.1) : AppColors.lightGray,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isPremium ? feature['premium'] : feature['free'],
              style: GoogleFonts.epilogue(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPremium ? Colors.amber[700] : AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats(PremiumService premiumService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günlük Kullanım',
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildUsageBar(
            'Özel Yemek',
            premiumService.dailyCustomMealCount,
            PremiumService.maxDailyCustomMeals,
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildUsageBar(
            'AI Analizi',
            premiumService.weeklyAIAnalysisCount,
            PremiumService.maxWeeklyAIAnalysis,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar(String title, int current, int max, Color color) {
    final percentage = (current / max).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.epilogue(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '$current/$max',
              style: GoogleFonts.epilogue(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingPlans(PremiumService premiumService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Planları',
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildPricingCard(
          'Aylık Premium',
          '₺29,99',
          '/ay',
          'En popüler',
          PremiumService.monthlyPremiumId,
          premiumService,
        ),
        const SizedBox(height: 12),
        _buildPricingCard(
          'Yıllık Premium',
          '₺199,99',
          '/yıl',
          '%44 tasarruf',
          PremiumService.yearlyPremiumId,
          premiumService,
        ),
      ],
    );
  }

  Widget _buildPricingCard(
    String title,
    String price,
    String period,
    String badge,
    String productId,
    PremiumService premiumService,
  ) {
    final isPopular = badge == 'En popüler';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppColors.primary : Colors.grey.withOpacity(0.2),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPopular ? AppColors.primary : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.epilogue(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.epilogue(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                period,
                style: GoogleFonts.epilogue(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: premiumService.purchasePending 
                  ? null 
                  : () => _purchasePremium(productId, premiumService),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? AppColors.primary : Colors.grey[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: premiumService.purchasePending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Satın Al',
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBenefits() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.withOpacity(0.1), Colors.orange.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.diamond, color: Colors.amber[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Premium Avantajlarınız',
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...PremiumService().getPremiumFeatures().map((feature) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.epilogue(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PremiumService premiumService) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _restorePurchases(premiumService),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Satın Alımları Geri Yükle',
              style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Premium üyeliğinizi istediğiniz zaman App Store veya Google Play Store üzerinden iptal edebilirsiniz.',
          textAlign: TextAlign.center,
          style: GoogleFonts.epilogue(
            fontSize: 12,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Terms of service
              },
              child: Text(
                'Kullanım Şartları',
                style: GoogleFonts.epilogue(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
            Text(' • ', style: TextStyle(color: AppColors.textMedium)),
            TextButton(
              onPressed: () {
                // Privacy policy
              },
              child: Text(
                'Gizlilik Politikası',
                style: GoogleFonts.epilogue(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _purchasePremium(String productId, PremiumService premiumService) async {
    try {
      await premiumService.purchasePremium(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Premium satın alma işlemi başlatıldı'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alma hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases(PremiumService premiumService) async {
    try {
      await premiumService.initialize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alımlar kontrol ediliyor...'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geri yükleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 