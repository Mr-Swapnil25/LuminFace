import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import 'theme.dart';
import 'user_model.dart';
import 'auth_service.dart';
import 'gemini_service.dart';
import 'analysis_result_screen.dart';

class ScanScreen extends StatefulWidget {
  final UserModel user;
  final bool isDarkMode;

  const ScanScreen({
    Key? key,
    required this.user,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFrontCamSelected = true;
  bool _isCapturing = false;
  bool _hasPermission = false;
  bool _showPermissionDialog = false;
  bool _showTips = true;
  
  // Face detection guidelines overlay
  final List<String> _faceTips = [
    'Position your face in the oval',
    'Ensure good lighting',
    'Remove glasses if possible',
    'Keep a neutral expression',
  ];
  int _currentTipIndex = 0;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndInitCamera();
    
    // Cycle through face tips
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _faceTips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes for camera
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // Check camera permissions
  Future<void> _checkPermissionAndInitCamera() async {
    final cameraPermission = await Permission.camera.status;
    
    if (cameraPermission.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      await _initCamera();
    } else {
      setState(() {
        _showPermissionDialog = true;
      });
    }
  }

  // Request camera permission
  Future<void> _requestCameraPermission() async {
    final permissionStatus = await Permission.camera.request();
    
    if (permissionStatus.isGranted) {
      setState(() {
        _hasPermission = true;
        _showPermissionDialog = false;
      });
      await _initCamera();
    } else {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  // Initialize camera
  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    
    if (_cameras == null || _cameras!.isEmpty) {
      return;
    }
    
    // Get front camera
    final frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );
    
    // Initialize camera controller
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    await _cameraController!.initialize();
    
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
        _isFrontCamSelected = frontCamera.lensDirection == CameraLensDirection.front;
      });
    }
  }

  // Switch between front and back camera
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.isEmpty || _cameraController == null) {
      return;
    }
    
    final lensDirection = _cameraController!.description.lensDirection;
    CameraDescription newCamera;
    
    if (lensDirection == CameraLensDirection.front) {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
    } else {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
    }
    
    if (newCamera != null) {
      await _cameraController!.dispose();
      
      _cameraController = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isFrontCamSelected = newCamera.lensDirection == CameraLensDirection.front;
        });
      }
    }
  }

  // Take picture
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }
    
    setState(() {
      _isCapturing = true;
    });
    
    try {
      // Capture image
      final XFile imageFile = await _cameraController!.takePicture();
      
      // Process image
      await _processAndAnalyzeImage(File(imageFile.path));
    } catch (e) {
      print('Error taking picture: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error capturing image. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.richBerry,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 90,
      );
      
      if (pickedFile != null) {
        await _processAndAnalyzeImage(File(pickedFile.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error selecting image. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.richBerry,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  // Process and analyze the image
  Future<void> _processAndAnalyzeImage(File imageFile) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildLoadingDialog(),
    );
    
    try {
      // Get temporary directory for saving processed image
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/processed_image.jpg';
      
      // Convert image to base64 string for API
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      // Save processed image
      final processedFile = File(tempPath);
      await processedFile.writeAsBytes(img.encodeJpg(image!, quality: 90));
      
      // Get Gemini service
      final geminiService = GeminiService();
      
      // Either call the API or use mock data for testing
      Map<String, dynamic> analysisResult;
      
      // For testing/debugging, use mock data
      if (true) { // Change to false in production
        analysisResult = geminiService.getMockAnalysis();
      } else {
        // Encode image to base64
        final String base64Image = await imageFile.readAsBytes().then((bytes) {
          return base64Encode(bytes);
        });
        
        // Call Gemini API
        final rawResults = await geminiService.analyzeSkin(
          imageBase64: base64Image,
          gender: widget.user.gender,
          ageGroup: widget.user.ageGroup,
        );
        
        // Parse results
        analysisResult = geminiService.parseAnalysisResults(rawResults);
      }
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Save analysis to user history
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Create skin analysis object
      final SkinAnalysis analysis = SkinAnalysis(
        dateTime: DateTime.now(),
        imageUrl: 'file://${processedFile.path}', // This would be a Firebase Storage URL in production
        skinTone: analysisResult['skinTone'],
        glowScore: analysisResult['glowScore'],
        wrinkleZones: analysisResult['wrinkleZones'],
        blemishZones: analysisResult['blemishZones'],
        symmetryScore: analysisResult['symmetryScore'],
        suggestions: analysisResult['suggestions'],
      );
      
      // Add to user history
      await authService.addSkinAnalysis(
        uid: widget.user.uid,
        analysis: analysis,
      );
      
      // Navigate to results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(
            analysis: analysis,
            user: widget.user,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      print('Error processing image: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error analyzing skin. Please try again.',
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
            'Skin Analysis',
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
                _showTips ? Icons.info_outline : Icons.info,
                color: AppTheme.orchidPink,
              ),
              onPressed: () {
                setState(() {
                  _showTips = !_showTips;
                });
              },
            ),
          ],
        ),
        body: _hasPermission
            ? _buildCameraView()
            : _buildPermissionView(),
      ),
    );
  }

  Widget _buildPermissionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_rounded,
              size: 80,
              color: AppTheme.orchidPink.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Access Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To analyze your skin, we need permission to use your camera. Your photos will never be shared without your consent.',
              style: TextStyle(
                fontSize: 16,
                color: widget.isDarkMode 
                    ? Colors.white.withOpacity(0.7)
                    : AppTheme.cocoaGray.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: AppTheme.gradientButtonDecoration,
                child: Container(
                  height: 55,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Grant Camera Access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _pickImageFromGallery,
              icon: Icon(Icons.photo_library_rounded),
              label: Text('Use Gallery Instead'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.orchidPink,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.orchidPink,
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
        
        // Face oval overlay
        Positioned.fill(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.orchidPink.withOpacity(0.7),
                  width: 2.5,
                ),
                borderRadius: BorderRadius.all(Radius.elliptical(
                  MediaQuery.of(context).size.width * 0.4,
                  MediaQuery.of(context).size.height * 0.3,
                )),
              ),
            ),
          ),
        ),
        
        // Capture button and gallery button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Switch camera button
              InkWell(
                onTap: _switchCamera,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.roseGold.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flip_camera_android_rounded,
                    color: AppTheme.roseGold,
                    size: 30,
                  ),
                ),
              ),
              
              // Capture button
              InkWell(
                onTap: _takePicture,
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.orchidPink.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isCapturing
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                ),
              ),
              
              // Gallery button
              InkWell(
                onTap: _pickImageFromGallery,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.blushNude.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: AppTheme.blushNude,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Tips cards
        if (_showTips)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey<int>(_currentTipIndex),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? AppTheme.softCharcoal.withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDarkMode
                            ? Colors.black.withOpacity(0.2)
                            : AppTheme.mauveMist.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.orchidPink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _faceTips[_currentTipIndex],
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white
                              : AppTheme.cocoaGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? AppTheme.softCharcoal
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.orchidPink,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Analyzing your skin...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: widget.isDarkMode
                    ? Colors.white
                    : AppTheme.cocoaGray,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Our AI is examining your facial features to provide personalized insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isDarkMode
                    ? Colors.white70
                    : AppTheme.cocoaGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 