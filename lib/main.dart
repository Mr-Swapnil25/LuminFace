import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

import 'theme.dart';
import 'home_screen.dart';
import 'auth_service.dart';
import 'user_model.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run app
  runApp(const LuminFaceApp());
}

class LuminFaceApp extends StatefulWidget {
  const LuminFaceApp({Key? key}) : super(key: key);

  @override
  _LuminFaceAppState createState() => _LuminFaceAppState();
}

class _LuminFaceAppState extends State<LuminFaceApp> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  bool isDarkMode = false;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserThemePreference();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangePlatformBrightness() {
    // Respond to system brightness changes if the user hasn't set a preference
    if (!_isInitialized) {
      _updateThemeBasedOnSystem();
    }
    super.didChangePlatformBrightness();
  }
  
  // Update theme based on system settings if user hasn't set a preference
  void _updateThemeBasedOnSystem() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final systemDarkMode = brightness == Brightness.dark;
    
    setState(() {
      isDarkMode = systemDarkMode;
    });
  }

  // Load user theme preference from Firestore if user is logged in
  Future<void> _loadUserThemePreference() async {
    try {
      // First set theme based on system
      _updateThemeBasedOnSystem();
      
      // Then try to load from user preferences
      UserModel? user = await _authService.getCurrentUserData();
      if (user != null) {
        setState(() {
          isDarkMode = user.isDarkMode;
          _isInitialized = true;
        });
      }
    } catch (e) {
      print("Error loading user theme preference: $e");
    }
  }

  // Update theme based on user preference
  void _updateTheme(bool darkMode) {
    setState(() {
      isDarkMode = darkMode;
      _isInitialized = true;
    });
    
    // Update user preferences in Firestore if user is signed in
    User? currentUser = _authService.currentUser;
    if (currentUser != null) {
      _authService.updateUserProfile(
        uid: currentUser.uid,
        isDarkMode: darkMode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: _authService.authStateChanges,
          initialData: null,
        ),
        Provider<AuthService>.value(
          value: _authService,
        ),
      ],
      child: MaterialApp(
        title: 'LuminFace Beauty',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: SplashScreen(
          authWrapper: AuthWrapper(
            updateTheme: _updateTheme,
            isDarkMode: isDarkMode,
          ),
        ),
      ),
    );
  }
}

// Splash screen to display while initializing
class SplashScreen extends StatefulWidget {
  final Widget authWrapper;
  
  const SplashScreen({
    Key? key,
    required this.authWrapper,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    
    // Navigate to the auth wrapper after a delay
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => widget.authWrapper,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.softCharcoal : AppTheme.ivoryWhite,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.orchidPink.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.spa_rounded,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // App name
              Text(
                'LuminFace',
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppTheme.cocoaGray,
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Tagline
              Text(
                'Reveal your skin\'s natural beauty',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDarkMode 
                    ? Colors.white.withOpacity(0.7) 
                    : AppTheme.cocoaGray.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Handles authentication state and redirects to appropriate screens
class AuthWrapper extends StatelessWidget {
  final Function(bool) updateTheme;
  final bool isDarkMode;

  const AuthWrapper({
    Key? key,
    required this.updateTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<User?>(context);
    final AuthService authService = Provider.of<AuthService>(context);

    if (user == null) {
      // User is not signed in, show login/signup screen
      return LoginScreen(updateTheme: updateTheme, isDarkMode: isDarkMode);
    } else {
      // User is signed in, fetch user data and show home screen
      return StreamBuilder<UserModel?>(
        stream: authService.userStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            UserModel? userData = snapshot.data;
            
            if (userData != null) {
              return HomeScreen(
                user: userData,
                updateTheme: updateTheme,
                isDarkMode: isDarkMode,
              );
            }
          }
          
          // Show loading while fetching user data
          return Scaffold(
            backgroundColor: isDarkMode 
                ? AppTheme.softCharcoal 
                : AppTheme.ivoryWhite,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.orchidPink,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading your profile...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : AppTheme.cocoaGray.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
} 