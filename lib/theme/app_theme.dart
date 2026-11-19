import 'package:flutter/material.dart';

/// Akıllı Liste – modern tema (açık + koyu)
/// Ana renk: nane/teal  |  Vurgu: mercan (öncelik, tarih, uyarı)
class AppColors {
  AppColors._();

  // Marka renkleri
  static const teal = Color(0xFF0F9D8A);
  static const tealLight = Color(0xFF4FD1BC);
  static const coral = Color(0xFFFF7A59);
  static const coralLight = Color(0xFFFF9A7E);

  // Açık tema yüzeyleri
  static const lightBg = Color(0xFFF2F7F6); // hafif nane tonlu arka plan
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFE8F1EF);
  static const lightText = Color(0xFF13262B);
  static const lightOutline = Color(0xFFD3E1DE);

  // Koyu tema yüzeyleri
  static const darkBg = Color(0xFF0D1416);
  static const darkSurface = Color(0xFF162124);
  static const darkSurfaceAlt = Color(0xFF1E2C30);
  static const darkText = Color(0xFFE4EFED);
  static const darkOutline = Color(0xFF2C3E42);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.teal,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFCDEFE8),
      onPrimaryContainer: const Color(0xFF00382F),
      secondary: const Color(0xFF4A6B66),
      tertiary: AppColors.coral,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFE1D9),
      onTertiaryContainer: const Color(0xFF5A1D0C),
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      surfaceContainerHighest: AppColors.lightSurfaceAlt,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutline,
    );
    return _build(scheme, AppColors.lightBg);
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.tealLight,
      onPrimary: const Color(0xFF00382F),
      primaryContainer: const Color(0xFF0B4F46),
      onPrimaryContainer: const Color(0xFFBDF2E8),
      secondary: const Color(0xFFA9C9C3),
      tertiary: AppColors.coralLight,
      onTertiary: const Color(0xFF4A1706),
      tertiaryContainer: const Color(0xFF6B2A15),
      onTertiaryContainer: const Color(0xFFFFDBD0),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkSurfaceAlt,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutline,
    );
    return _build(scheme, AppColors.darkBg);
  }

  static ThemeData _build(ColorScheme s, Color background) {
    final isDark = s.brightness == Brightness.dark;
    final radius = BorderRadius.circular(16);

    return ThemeData(
      useMaterial3: true,
      colorScheme: s,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: s.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: s.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: s.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: s.outline),
        ),
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: radius),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: const CircleBorder(), // yapılacaklar için yuvarlak tik
        side: BorderSide(color: s.primary, width: 2),
        fillColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.primary : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(s.onPrimary),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: s.primary,
        foregroundColor: s.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: s.primary,
          foregroundColor: s.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: s.outline),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: s.primary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceAlt : s.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.error),
        ),
        hintStyle: TextStyle(color: s.onSurface.withValues(alpha: 0.45)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: s.surfaceContainerHighest,
        selectedColor: s.primaryContainer,
        labelStyle: TextStyle(color: s.onSurface),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: s.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.lightText,
        contentTextStyle: TextStyle(
          color: isDark ? AppColors.darkText : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: s.surface,
        indicatorColor: s.primaryContainer,
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(color: s.outline, space: 1),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: s.primary),
    );
  }
}