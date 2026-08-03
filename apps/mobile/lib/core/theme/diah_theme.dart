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

  /// Apply a heavier weight across a text theme (keeps size/color).
  static TextTheme _thicken(TextTheme theme, FontWeight weight) {
    TextStyle? bump(TextStyle? s) => s?.copyWith(fontWeight: weight);
    return theme.copyWith(
      displayLarge: bump(theme.displayLarge),
      displayMedium: bump(theme.displayMedium),
      displaySmall: bump(theme.displaySmall),
      headlineLarge: bump(theme.headlineLarge),
      headlineMedium: bump(theme.headlineMedium),
      headlineSmall: bump(theme.headlineSmall),
      titleLarge: bump(theme.titleLarge),
      titleMedium: bump(theme.titleMedium),
      titleSmall: bump(theme.titleSmall),
      bodyLarge: bump(theme.bodyLarge),
      bodyMedium: bump(theme.bodyMedium),
      bodySmall: bump(theme.bodySmall),
      labelLarge: bump(theme.labelLarge),
      labelMedium: bump(theme.labelMedium),
      labelSmall: bump(theme.labelSmall),
    );
  }

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

    final display = _thicken(
      GoogleFonts.cormorantGaramondTextTheme(base.textTheme),
      FontWeight.w700,
    );
    final body = _thicken(
      GoogleFonts.dmSansTextTheme(base.textTheme),
      FontWeight.w600,
    );

    return base.copyWith(
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: display.displayMedium?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w800,
        ),
        displaySmall: display.displaySmall?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: display.headlineLarge?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: body.titleLarge?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: body.titleMedium?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: body.titleSmall?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: body.bodyLarge?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          color: DiahColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: body.bodySmall?.copyWith(
          color: DiahColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: body.labelLarge?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w700,
        ),
        labelMedium: body.labelMedium?.copyWith(
          color: DiahColors.text,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: body.labelSmall?.copyWith(
          color: DiahColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
      primaryTextTheme: _thicken(
        GoogleFonts.dmSansTextTheme(base.primaryTextTheme),
        FontWeight.w700,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DiahColors.background,
        foregroundColor: DiahColors.text,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: DiahColors.text,
        ),
        toolbarTextStyle: GoogleFonts.dmSans(
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
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
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
            fontWeight: FontWeight.w800,
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
        labelStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600,
          color: DiahColors.textSecondary,
        ),
        floatingLabelStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w700,
          color: DiahColors.primary,
        ),
        hintStyle: GoogleFonts.dmSans(
          color: DiahColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DiahColors.softLavender,
        selectedColor: DiahColors.primary,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: DiahColors.text,
        ),
        subtitleTextStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: DiahColors.textMuted,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DiahColors.card,
        selectedItemColor: DiahColors.primary,
        unselectedItemColor: DiahColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w800),
        unselectedLabelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
      dividerTheme: const DividerThemeData(
        color: DiahColors.border,
        thickness: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DiahColors.primary,
        foregroundColor: Colors.white,
        extendedTextStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w800),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: DiahColors.text,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: DiahColors.textSecondary,
        ),
      ),
    );
  }
}
