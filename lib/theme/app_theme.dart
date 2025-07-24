import 'package:flutter/material.dart';

class AppTheme {
  // Color Constants - Windows 11 / macOS inspired
  static const Color primaryBlue = Color(0xFF0078D4);
  static const Color primaryBlueHover = Color(0xFF106EBE);
  static const Color primaryBlueDark = Color(0xFF005A9E);
  
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D30);
  
  static const Color borderColor = Color(0xFF404040);
  static const Color borderColorLight = Color(0xFF606060);
  
  static const Color successGreen = Color(0xFF107C10);
  static const Color errorRed = Color(0xFFD13438);
  static const Color warningOrange = Color(0xFFFF8C00);
  
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDisabled = Color(0xFF666666);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryBlueHover,
      surface: darkSurface,
      background: darkBackground,
      onSurface: textPrimary,
      onBackground: textPrimary,
      error: errorRed,
      onError: Colors.white,
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: darkSurfaceVariant,
        disabledForegroundColor: textDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: borderColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceVariant.withOpacity(0.7),
      labelStyle: const TextStyle(
        color: textSecondary,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        color: textDisabled,
        fontSize: 14,
      ),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorStyle: const TextStyle(
        color: errorRed,
        fontSize: 12,
      ),
    ),
    
    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryBlue;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: borderColor, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: darkSurface,
      shadowColor: Colors.black.withOpacity(0.3),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: const TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: textSecondary,
        fontSize: 14,
      ),
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkSurface,
      contentTextStyle: const TextStyle(
        color: textPrimary,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 20,
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
      ),
      displayMedium: TextStyle(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: textDisabled,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: borderColor,
      thickness: 1,
      space: 1,
    ),
  );
}