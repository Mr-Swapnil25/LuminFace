import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'theme.dart';
import 'user_model.dart';
import 'auth_service.dart';
import 'analysis_screen.dart';
import 'results_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  final Function(bool) updateTheme;
  final bool isDarkMode;

  const HomeScreen({
    Key? key,
    required this.user,
    required this.updateTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['Home', 'Analyze', 'Results', 'Profile'];
  final List<IconData> _tabIcons = [
    Icons.home_rounded,
    Icons.camera_alt_rounded,
    Icons.analytics_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeTab(user: widget.user, isDarkMode: widget.isDarkMode),
            AnalysisScreen(user: widget.user, isDarkMode: widget.isDarkMode),
            ResultsScreen(user: widget.user, isDarkMode: widget.isDarkMode),
            ProfileScreen(
              user: widget.user,
              updateTheme: widget.updateTheme,
              isDarkMode: widget.isDarkMode,
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppTheme.softCharcoal : Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.mauveMist.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: TabBar(
          controller: _tabController,
          labelColor: AppTheme.orchidPink,
          unselectedLabelColor: widget.isDarkMode
              ? Colors.white.withOpacity(0.5)
              : AppTheme.cocoaGray.withOpacity(0.5),
          indicatorColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          tabs: List.generate(
            _tabTitles.length,
            (index) => _buildTabItem(_tabIcons[index], _tabTitles[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class HomeTab extends StatelessWidget {
  final UserModel user;
  final bool isDarkMode;

  const HomeTab({
    Key? key,
    required this.user,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.softCharcoal : AppTheme.ivoryWhite,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 100,
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: false,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Hello, ${user.fullName.split(' ').first}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLastScanCard(context),
                    const SizedBox(height: 24),
                    _buildQuickActionsSection(context),
                    const SizedBox(height: 24),
                    _buildTipsCarousel(context),
                    const SizedBox(height: 24),
                    if (user.skinGoal != null) _buildSkinGoalCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastScanCard(BuildContext context) {
    // Check if user has a skin analysis history
    final bool hasScanHistory = user.skinHistory != null && user.skinHistory!.isNotEmpty;
    
    return Card(
      elevation: 0,
      color: isDarkMode ? Color(0xFF252327) : Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasScanHistory ? 'Your Last Scan' : 'Start Your Journey',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasScanHistory)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.orchidPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: AppTheme.orchidPink,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (hasScanHistory)
                _buildLastScanDetails()
              else
                _buildNoScanMessage(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastScanDetails() {
    // Get the most recent scan
    final SkinAnalysis lastScan = user.skinHistory!.last;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // User image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(lastScan.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Skin metrics
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricRow(
                    'Glow Score',
                    '${(lastScan.glowScore * 100).toInt()}%',
                    AppTheme.orchidPink,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    'Skin Tone',
                    lastScan.skinTone,
                    AppTheme.roseGold,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    'Symmetry',
                    '${(lastScan.symmetryScore * 100).toInt()}%',
                    AppTheme.blushNude,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Personalized Suggestions:',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...lastScan.suggestions.take(2).map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.arrow_right_rounded,
                color: AppTheme.orchidPink,
                size: 20,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  suggestion,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : AppTheme.cocoaGray.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : AppTheme.cocoaGray.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoScanMessage(BuildContext context) {
    return Column(
      children: [
        Text(
          'Take your first scan to get personalized skin analysis and beauty recommendations.',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : AppTheme.cocoaGray.withOpacity(0.7),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            // Navigate to scan tab
            DefaultTabController.of(context)?.animateTo(1);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: AppTheme.gradientButtonDecoration,
            child: const Center(
              child: Text(
                'Start Skin Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildQuickActionCard(
              context,
              icon: Icons.camera_alt_rounded,
              label: 'New Scan',
              color: AppTheme.orchidPink,
              onTap: () {
                // Navigate to scan tab
                DefaultTabController.of(context)?.animateTo(1);
              },
            ),
            const SizedBox(width: 16),
            _buildQuickActionCard(
              context,
              icon: Icons.analytics_rounded,
              label: 'View Results',
              color: AppTheme.blushNude,
              onTap: () {
                // Navigate to results tab
                DefaultTabController.of(context)?.animateTo(2);
              },
            ),
            const SizedBox(width: 16),
            _buildQuickActionCard(
              context,
              icon: Icons.track_changes_rounded,
              label: 'Set Goal',
              color: AppTheme.roseGold,
              onTap: () {
                // Navigate to profile tab
                DefaultTabController.of(context)?.animateTo(3);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF252327) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.mauveMist.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCarousel(BuildContext context) {
    final List<Map<String, dynamic>> tips = [
      {
        'title': 'Morning Skincare',
        'description': 'Start with a gentle cleanser, then apply vitamin C serum for antioxidant protection.',
        'icon': Icons.wb_sunny_rounded,
        'color': AppTheme.blushNude,
      },
      {
        'title': 'Hydration Boost',
        'description': 'Drink at least 8 glasses of water daily for plump, glowing skin.',
        'icon': Icons.water_drop_rounded,
        'color': AppTheme.roseGold,
      },
      {
        'title': 'Sun Protection',
        'description': 'Always apply SPF 30+ sunscreen, even on cloudy days to prevent aging.',
        'icon': Icons.light_mode_rounded,
        'color': AppTheme.orchidPink,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beauty Tips',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tips.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tip['color'],
                      tip['color'].withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: tip['color'].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            tip['icon'],
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tip['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tip['description'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Learn More',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkinGoalCard(BuildContext context) {
    final SkinGoal skinGoal = user.skinGoal!;
    final double progress = skinGoal.progressPercentage.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Skin Goal',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: isDarkMode ? Color(0xFF252327) : Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          skinGoal.description,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.richBerry.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flag_rounded,
                          color: AppTheme.richBerry,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? Colors.white.withOpacity(0.1) 
                          : AppTheme.mauveMist.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: (MediaQuery.of(context).size.width - 64) * (progress / 100),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.orchidPink, AppTheme.blushNude],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: isDarkMode 
                              ? Colors.white70 
                              : AppTheme.cocoaGray.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${progress.toInt()}%',
                        style: TextStyle(
                          color: AppTheme.orchidPink,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 