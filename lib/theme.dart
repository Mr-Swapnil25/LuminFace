import 'package:flutter/material.dart';

class AppTheme {
  // Premium Color Palette
  static const Color ivoryWhite = Color(0xFFFFF9F5);
  static const Color softCharcoal = Color(0xFF1D1B1E);
  static const Color orchidPink = Color(0xFFEFA6BF);
  static const Color blushNude = Color(0xFFF7C6BA);
  static const Color roseGold = Color(0xFFE6B8A2);
  static const Color richBerry = Color(0xFF8E3B60);
  static const Color mauveMist = Color(0xFFD3BFD4);
  static const Color cocoaGray = Color(0xFF3A3335);
  static const Color lightChampagne = Color(0xFFF5E2D8);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ivoryWhite,
    primaryColor: orchidPink,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.light(
      primary: orchidPink,
      secondary: blushNude,
      tertiary: roseGold,
      background: ivoryWhite,
      surface: ivoryWhite,
      error: richBerry,
      onPrimary: Colors.white,
      onSecondary: cocoaGray,
      onTertiary: cocoaGray,
      onBackground: cocoaGray,
      onSurface: cocoaGray,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: cocoaGray, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      displayMedium: TextStyle(color: cocoaGray, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      displaySmall: TextStyle(color: cocoaGray, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      headlineLarge: TextStyle(color: cocoaGray, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      headlineMedium: TextStyle(color: cocoaGray, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      headlineSmall: TextStyle(color: cocoaGray, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      titleLarge: TextStyle(color: cocoaGray, fontWeight: FontWeight.w500, letterSpacing: -0.2),
      titleMedium: TextStyle(color: cocoaGray, fontWeight: FontWeight.w500, letterSpacing: -0.2),
      titleSmall: TextStyle(color: cocoaGray, fontWeight: FontWeight.w500, letterSpacing: -0.2),
      bodyLarge: TextStyle(color: cocoaGray, fontWeight: FontWeight.w400, letterSpacing: 0),
      bodyMedium: TextStyle(color: cocoaGray, fontWeight: FontWeight.w400, letterSpacing: 0),
      bodySmall: TextStyle(color: cocoaGray, fontWeight: FontWeight.w400, letterSpacing: 0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(color: mauveMist, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(color: mauveMist, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(color: orchidPink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(color: richBerry),
      ),
      labelStyle: TextStyle(color: cocoaGray.withOpacity(0.7), fontWeight: FontWeight.w400),
      hintStyle: TextStyle(color: cocoaGray.withOpacity(0.5), fontWeight: FontWeight.w400),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return mauveMist.withOpacity(0.5);
            }
            return orchidPink;
          },
        ),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        elevation: MaterialStateProperty.all(6.0),
        shadowColor: MaterialStateProperty.all(orchidPink.withOpacity(0.5)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        ),
        overlayColor: MaterialStateProperty.all(richBerry.withOpacity(0.1)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(orchidPink),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        overlayColor: MaterialStateProperty.all(orchidPink.withOpacity(0.05)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(orchidPink),
        side: MaterialStateProperty.all(BorderSide(color: orchidPink, width: 1.5)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ivoryWhite,
      foregroundColor: cocoaGray,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: cocoaGray, 
        fontSize: 22, 
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    iconTheme: IconThemeData(
      color: orchidPink,
      size: 24,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: orchidPink,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: mauveMist.withOpacity(0.3),
      thickness: 1.0,
      space: 24,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: blushNude.withOpacity(0.15),
      disabledColor: mauveMist.withOpacity(0.1),
      selectedColor: orchidPink.withOpacity(0.2),
      secondarySelectedColor: richBerry.withOpacity(0.2),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelStyle: TextStyle(color: cocoaGray),
      secondaryLabelStyle: TextStyle(color: richBerry),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cocoaGray,
      contentTextStyle: TextStyle(color: ivoryWhite),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: softCharcoal,
    primaryColor: orchidPink,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.dark(
      primary: orchidPink,
      secondary: blushNude,
      tertiary: roseGold,
      background: softCharcoal,
      surface: Color(0xFF252327),
      error: richBerry,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: -0.5),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: -0.2),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: -0.2),
      titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: -0.2),
      bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, letterSpacing: 0),
      bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, letterSpacing: 0),
      bodySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, letterSpacing: 0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2A282B),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(color: mauveMist.withOpacity(0.3), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(color: mauveMist.withOpacity(0.3), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(color: orchidPink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(color: richBerry),
      ),
      labelStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w400),
      hintStyle: TextStyle(color: Colors.white60, fontWeight: FontWeight.w400),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return mauveMist.withOpacity(0.3);
            }
            return orchidPink;
          },
        ),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        elevation: MaterialStateProperty.all(6.0),
        shadowColor: MaterialStateProperty.all(orchidPink.withOpacity(0.5)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        ),
        overlayColor: MaterialStateProperty.all(richBerry.withOpacity(0.2)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(orchidPink),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        overlayColor: MaterialStateProperty.all(orchidPink.withOpacity(0.15)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(orchidPink),
        side: MaterialStateProperty.all(BorderSide(color: orchidPink, width: 1.5)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF252327),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: softCharcoal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white, 
        fontSize: 22, 
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    iconTheme: IconThemeData(
      color: orchidPink,
      size: 24,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: orchidPink,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: mauveMist.withOpacity(0.2),
      thickness: 1.0,
      space: 24,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: blushNude.withOpacity(0.15),
      disabledColor: mauveMist.withOpacity(0.1),
      selectedColor: orchidPink.withOpacity(0.3),
      secondarySelectedColor: richBerry.withOpacity(0.3),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelStyle: TextStyle(color: Colors.white),
      secondaryLabelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF2A282B),
      contentTextStyle: TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Gradient Button Style
  static LinearGradient primaryGradient = LinearGradient(
    colors: [orchidPink, blushNude],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient secondaryGradient = LinearGradient(
    colors: [roseGold, blushNude.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient accentGradient = LinearGradient(
    colors: [richBerry, orchidPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration gradientButtonDecoration = BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(20.0),
    boxShadow: [
      BoxShadow(
        color: orchidPink.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration secondaryGradientDecoration = BoxDecoration(
    gradient: secondaryGradient,
    borderRadius: BorderRadius.circular(20.0),
    boxShadow: [
      BoxShadow(
        color: roseGold.withOpacity(0.25),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration accentGradientDecoration = BoxDecoration(
    gradient: accentGradient,
    borderRadius: BorderRadius.circular(20.0),
    boxShadow: [
      BoxShadow(
        color: richBerry.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  // Card Shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: mauveMist.withOpacity(0.15),
      blurRadius: 15,
      offset: Offset(0, 5),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 15,
      offset: Offset(0, 5),
      spreadRadius: 0,
    ),
  ];
  
  // Animation Durations
  static Duration shortAnimationDuration = Duration(milliseconds: 200);
  static Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Common Curves
  static Curve defaultCurve = Curves.easeInOut;
  static Curve bouncyCurve = Curves.elasticOut;
} 