import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'theme.dart';
import 'user_model.dart';

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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDarkMode
              ? AppTheme.darkCardShadow
              : AppTheme.cardShadow,
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
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(lastScan.imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.mauveMist.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
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
        )).toList(),
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
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: AppTheme.gradientButtonDecoration,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.camera_alt_rounded,
                title: 'New Scan',
                color: AppTheme.orchidPink,
                onTap: () {
                  // Navigate to scan tab
                  DefaultTabController.of(context)?.animateTo(1);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.analytics_rounded,
                title: 'History',
                color: AppTheme.blushNude,
                onTap: () {
                  // Navigate to results tab
                  DefaultTabController.of(context)?.animateTo(2);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.person_rounded,
                title: 'Profile',
                color: AppTheme.roseGold,
                onTap: () {
                  // Navigate to profile tab
                  DefaultTabController.of(context)?.animateTo(3);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF252327) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDarkMode
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppTheme.mauveMist.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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
        'content': 'Always apply sunscreen even on cloudy days to protect from UV damage.',
        'icon': Icons.wb_sunny_rounded,
        'color': AppTheme.roseGold,
      },
      {
        'title': 'Stay Hydrated',
        'content': 'Drink plenty of water throughout the day for glowing, healthy skin.',
        'icon': Icons.water_drop_rounded,
        'color': AppTheme.blushNude,
      },
      {
        'title': 'Beauty Sleep',
        'content': 'Get 7-8 hours of quality sleep to allow your skin to repair and regenerate.',
        'icon': Icons.nightlight_round,
        'color': AppTheme.orchidPink,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beauty Tips',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF252327) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDarkMode
                      ? AppTheme.darkCardShadow
                      : AppTheme.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tip['color'].withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tip['icon'],
                              color: tip['color'],
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            tip['title'],
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          tip['content'],
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white70
                                : AppTheme.cocoaGray.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Show more tips logic
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: tip['color'],
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('Read More'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 