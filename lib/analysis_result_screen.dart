import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:fl_chart/fl_chart.dart';

import 'theme.dart';
import 'user_model.dart';

class AnalysisResultScreen extends StatefulWidget {
  final SkinAnalysis analysis;
  final UserModel user;
  final bool isDarkMode;

  const AnalysisResultScreen({
    Key? key,
    required this.analysis,
    required this.user,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _AnalysisResultScreenState createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> with SingleTickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Share results as image
  Future<void> _shareResults() async {
    try {
      // Capture the screen as an image
      final Uint8List? imageBytes = await _screenshotController.capture();
      
      if (imageBytes != null) {
        // Get temporary directory to save the image
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/skin_analysis_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png';
        final File imageFile = File(imagePath);
        
        // Save the image
        await imageFile.writeAsBytes(imageBytes);
        
        // Share the image
        await Share.shareFiles(
          [imagePath],
          text: 'My LuminFace Skin Analysis',
          subject: 'Skin Analysis Results',
        );
      }
    } catch (e) {
      print('Error sharing results: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sharing results. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.richBerry,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: widget.isDarkMode
            ? AppTheme.softCharcoal
            : AppTheme.ivoryWhite,
        appBar: AppBar(
          title: Text(
            'Analysis Results',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_rounded,
                color: AppTheme.orchidPink,
              ),
              onPressed: _shareResults,
            ),
          ],
        ),
        body: Screenshot(
          controller: _screenshotController,
          child: Column(
            children: [
              _buildHeader(),
              Container(
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: widget.isDarkMode
                      ? Colors.white70
                      : AppTheme.cocoaGray.withOpacity(0.7),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: 'Summary'),
                    Tab(text: 'Analysis'),
                    Tab(text: 'Suggestions'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSummaryTab(),
                    _buildAnalysisTab(),
                    _buildSuggestionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // User profile image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: widget.analysis.imageUrl.startsWith('file://')
                    ? FileImage(File(widget.analysis.imageUrl.substring(7))) as ImageProvider
                    : NetworkImage(widget.analysis.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.orchidPink.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Analysis info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${widget.user.fullName.split(' ').first}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Analysis date: ${DateFormat('MMMM d, yyyy').format(widget.analysis.dateTime)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDarkMode
                        ? Colors.white70
                        : AppTheme.cocoaGray.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                // Overall score card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.orchidPink.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Beauty Score: ${((widget.analysis.glowScore + widget.analysis.symmetryScore) / 2 * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Skin tone card
        _buildInfoCard(
          title: 'Your Skin Tone',
          content: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getSkinToneColors(widget.analysis.skinTone),
                      ),
                      shape: BoxShape.circle,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.analysis.skinTone,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your skin has a beautiful ${_getSkinToneDescription(widget.analysis.skinTone)} undertone.',
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white70
                                : AppTheme.cocoaGray.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildExpandableInfo(
                title: 'What does this mean?',
                content: 'Your skin tone affects which colors and products work best for you. Understanding your undertone helps you choose makeup and clothing that enhances your natural beauty.',
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Score summary card
        _buildInfoCard(
          title: 'Your Skin Metrics',
          content: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreIndicator(
                    'Glow',
                    widget.analysis.glowScore,
                    AppTheme.orchidPink,
                  ),
                  _buildScoreIndicator(
                    'Symmetry',
                    widget.analysis.symmetryScore,
                    AppTheme.blushNude,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildExpandableInfo(
                title: 'What affects these scores?',
                content: 'Glow score reflects skin hydration, smoothness and radiance. Symmetry measures facial balance and proportions. Both contribute to overall facial harmony.',
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAnalysisTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Blemish zones card
        _buildInfoCard(
          title: 'Blemish Analysis',
          content: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                height: 240,
                child: Stack(
                  children: [
                    // Face outline
                    Center(
                      child: Container(
                        width: 180,
                        height: 240,
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.black.withOpacity(0.2)
                              : Colors.white,
                          borderRadius: BorderRadius.all(Radius.elliptical(180, 240)),
                          border: Border.all(
                            color: widget.isDarkMode
                                ? Colors.white30
                                : AppTheme.cocoaGray.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    
                    // Forehead
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildFacialZone(
                          'Forehead',
                          widget.analysis.blemishZones['forehead'] ?? 0.0,
                          width: 120,
                          height: 50,
                        ),
                      ),
                    ),
                    
                    // T-Zone
                    Positioned(
                      top: 65,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildFacialZone(
                          'T-Zone',
                          widget.analysis.blemishZones['tZone'] ?? 0.0,
                          width: 30,
                          height: 60,
                        ),
                      ),
                    ),
                    
                    // Cheeks
                    Positioned(
                      top: 90,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFacialZone(
                            'Left Cheek',
                            widget.analysis.blemishZones['cheeks'] ?? 0.0,
                            width: 50,
                            height: 50,
                            offsetX: -75,
                          ),
                          _buildFacialZone(
                            'Right Cheek',
                            widget.analysis.blemishZones['cheeks'] ?? 0.0,
                            width: 50,
                            height: 50,
                            offsetX: 75,
                          ),
                        ],
                      ),
                    ),
                    
                    // Chin
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildFacialZone(
                          'Chin',
                          widget.analysis.blemishZones['chin'] ?? 0.0,
                          width: 60,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              _buildExpandableInfo(
                title: 'What causes blemishes?',
                content: 'Blemishes can be caused by excess oil production, bacteria, hormones, or environmental factors. Areas with higher scores may benefit from targeted treatments.',
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Wrinkle zones card
        _buildInfoCard(
          title: 'Wrinkle Analysis',
          content: Column(
            children: [
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.5,
                child: RadarChart(
                  RadarChartData(
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData: const BorderSide(color: Colors.transparent),
                    tickCount: 5,
                    gridBorderData: BorderSide(
                      color: widget.isDarkMode
                          ? Colors.white30
                          : AppTheme.cocoaGray.withOpacity(0.1),
                      width: 1,
                    ),
                    tickBorderData: BorderSide(
                      color: widget.isDarkMode
                          ? Colors.white30
                          : AppTheme.cocoaGray.withOpacity(0.1),
                      width: 1,
                    ),
                    getTitle: (index, angle) {
                      final titles = [
                        'Forehead',
                        'Eyes',
                        'Mouth',
                        'Neck'
                      ];
                      return RadarChartTitle(
                        text: titles[index],
                        angle: angle,
                        positionPercentageOffset: 0.1,
                      );
                    },
                    titleTextStyle: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.white70
                          : AppTheme.cocoaGray.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    ticksTextStyle: TextStyle(
                      color: Colors.transparent,
                      fontSize: 8,
                    ),
                    dataSets: [
                      RadarDataSet(
                        fillColor: AppTheme.richBerry.withOpacity(0.25),
                        borderColor: AppTheme.richBerry,
                        entryRadius: 3,
                        dataEntries: [
                          RadarEntry(value: widget.analysis.wrinkleZones['forehead'] ?? 0.0),
                          RadarEntry(value: widget.analysis.wrinkleZones['eyesArea'] ?? 0.0),
                          RadarEntry(value: widget.analysis.wrinkleZones['mouthArea'] ?? 0.0),
                          RadarEntry(value: widget.analysis.wrinkleZones['neckArea'] ?? 0.0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              _buildExpandableInfo(
                title: 'Understanding wrinkle patterns',
                content: 'Fine lines and wrinkles develop over time due to aging, UV exposure, facial movements, and lifestyle factors. Areas with higher scores may benefit from targeted anti-aging products.',
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuggestionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'Your Personalized Routine',
          content: Column(
            children: [
              const SizedBox(height: 8),
              ...widget.analysis.suggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.orchidPink.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Divider(
                              color: widget.isDarkMode
                                  ? Colors.white24
                                  : AppTheme.mauveMist.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 16),
              _buildExpandableInfo(
                title: 'Why these suggestions?',
                content: 'These recommendations are based on your unique skin analysis results. They target your specific concerns and aim to enhance your natural beauty.',
              ),
              
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // In a real app, this would navigate to product recommendations
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Product recommendations coming soon!',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.blushNude,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: AppTheme.secondaryGradientDecoration,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'View Recommended Products',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoCard({required String title, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Color(0xFF252327) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.isDarkMode
            ? AppTheme.darkCardShadow
            : AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
              ),
            ),
          ),
          Divider(
            color: widget.isDarkMode
                ? Colors.white10
                : AppTheme.mauveMist.withOpacity(0.2),
            thickness: 1,
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreIndicator(String label, double score, Color color) {
    final percentage = (score * 100).toInt();
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDarkMode
                    ? Colors.white10
                    : color.withOpacity(0.1),
              ),
            ),
            CircularProgressIndicator(
              value: score,
              strokeWidth: 8,
              backgroundColor: widget.isDarkMode
                  ? Colors.black26
                  : Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white70 : AppTheme.cocoaGray.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildExpandableInfo({required String title, required String content}) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.orchidPink,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDarkMode
                    ? Colors.white70
                    : AppTheme.cocoaGray.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFacialZone(String label, double intensity, {
    required double width,
    required double height,
    double offsetX = 0,
  }) {
    final color = intensity <= 0.3
        ? Colors.green
        : intensity <= 0.6
            ? Colors.orange
            : Colors.red;
    
    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Tooltip(
        message: '$label: ${(intensity * 100).toInt()}%',
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(max(0.15, intensity)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
  
  List<Color> _getSkinToneColors(String skinTone) {
    // Map skin tone descriptions to appropriate gradient colors
    if (skinTone.toLowerCase().contains('fair') || 
        skinTone.toLowerCase().contains('light')) {
      return [Color(0xFFFEE5D3), Color(0xFFFFD9C0)];
    } else if (skinTone.toLowerCase().contains('medium')) {
      return [Color(0xFFEBC8A4), Color(0xFFDAAD85)];
    } else if (skinTone.toLowerCase().contains('olive') ||
              skinTone.toLowerCase().contains('tan')) {
      return [Color(0xFFD5AA8C), Color(0xFFC19070)];
    } else if (skinTone.toLowerCase().contains('brown') ||
              skinTone.toLowerCase().contains('deep')) {
      return [Color(0xFFA67358), Color(0xFF8C5F4A)];
    } else if (skinTone.toLowerCase().contains('dark') ||
              skinTone.toLowerCase().contains('deep')) {
      return [Color(0xFF8C5F4A), Color(0xFF614034)];
    } else {
      // Default
      return [AppTheme.blushNude, AppTheme.roseGold];
    }
  }
  
  String _getSkinToneDescription(String skinTone) {
    // Extract undertone information
    if (skinTone.toLowerCase().contains('warm')) {
      return 'warm';
    } else if (skinTone.toLowerCase().contains('cool')) {
      return 'cool';
    } else if (skinTone.toLowerCase().contains('neutral')) {
      return 'neutral';
    } else if (skinTone.toLowerCase().contains('olive')) {
      return 'olive';
    } else if (skinTone.toLowerCase().contains('golden')) {
      return 'golden';
    } else {
      return 'natural';
    }
  }
} 