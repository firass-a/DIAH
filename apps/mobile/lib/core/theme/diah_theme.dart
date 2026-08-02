import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiahColors {
  DiahColors._();

  static const Color primary = Color(0xFF887893);
  static const Color background = Color(0xFFF8F5FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFD3C4D5);
  static const Color accent = Color(0xFFB2A0B7);
  static const Color text = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B6570);
  static const Color textMuted = Color(0xFF9A93A0);
  static const Color border = Color(0xFFE8E2EC);
  static const Color success = Color(0xFF5A8F7B);
  static const Color error = Color(0xFFC45B5B);
  static const Color warning = Color(0xFFC49A5B);
  static const Color headingLight = Color(0xFFF1F1F1);
  static const Color softLavender = Color(0xFFF3EEF5);
}

class DiahTheme {
  DiahTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DiahColors.primary,
        primary: DiahColors.primary,
        secondary: DiahColors.secondary,
        surface: DiahColors.card,
        error: DiahColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: DiahColors.background,
    );

    final display = GoogleFonts.cormorantGaramondTextTheme(base.textTheme);
    final body = GoogleFonts.dmSansTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        displayMedium: display.displayMedium?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: display.displaySmall?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: display.headlineLarge?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: body.titleLarge?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: body.titleMedium?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: body.bodyLarge?.copyWith(color: DiahColors.text),
        bodyMedium: body.bodyMedium?.copyWith(color: DiahColors.textSecondary),
        bodySmall: body.bodySmall?.copyWith(color: DiahColors.textMuted),
        labelLarge: body.labelLarge?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DiahColors.background,
        foregroundColor: DiahColors.text,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: DiahColors.text,
        ),
      ),
      cardTheme: CardThemeData(
        color: DiahColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DiahColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DiahColors.primary,
          side: const BorderSide(color: DiahColors.primary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DiahColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DiahColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DiahColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DiahColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(color: DiahColors.textMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DiahColors.softLavender,
        selectedColor: DiahColors.primary,
        labelStyle: GoogleFonts.dmSans(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DiahColors.card,
        selectedItemColor: DiahColors.primary,
        unselectedItemColor: DiahColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: DiahColors.border,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DiahColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
