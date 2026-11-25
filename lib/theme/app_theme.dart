import 'package:flutter/material.dart';

/// Transisi halaman Material 3 yang halus (Shared-Axis Fade + Subtle Slide)
/// tanpa stutter/jank dari efek zoom berat pada layar Android maupun desktop.
class _SmoothM3PageTransitionsBuilder extends PageTransitionsBuilder {
  const _SmoothM3PageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(curved);

    final secondaryCurved = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.02, 0),
    ).animate(secondaryCurved);

    return SlideTransition(
      position: exitSlide,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(position: slideAnimation, child: child),
      ),
    );
  }
}

/// Palet warna dan tema Google Material 3 (Material You) StudyLog.
class AppTheme {
  static const Color _seedColor = Color(0xFF1A56DB);

  // Primary Palette (Google M3 Indigo / Blue Tonal)
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryContainer = Color(0xFFD8E2FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF001A41);
  static const Color primaryFixed = Color(0xFFD8E2FF);
  static const Color onPrimaryFixed = Color(0xFF001A41);

  // Secondary Palette (Cool M3 Slate Tonal)
  static const Color secondary = Color(0xFF565E71);
  static const Color secondaryContainer = Color(0xFFDAE2F9);
  static const Color onSecondaryContainer = Color(0xFF131C2B);
  static const Color onSecondaryFixedVariant = Color(0xFF3E4759);

  // Tertiary Palette (Soft M3 Emerald Tonal)
  static const Color tertiary = Color(0xFF006C4C);
  static const Color tertiaryContainer = Color(0xFFC2F0D8);
  static const Color onTertiaryContainer = Color(0xFF002113);
  static const Color tertiaryFixed = Color(0xFF8FF7C4);
  static const Color tertiaryFixedDim = Color(0xFF72DAA9);

  // Neutral / Surface Palette (Authentic M3 Tonal Light Surfaces)
  static const Color background = Color(0xFFF8F9FC);
  static const Color surface = Color(0xFFF8F9FC);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4FA);
  static const Color surfaceContainer = Color(0xFFECEFF7);
  static const Color surfaceContainerHigh = Color(0xFFE6EAF3);
  static const Color surfaceContainerHighest = Color(0xFFE0E4EE);
  static const Color onSurface = Color(0xFF191C20);
  static const Color onSurfaceVariant = Color(0xFF44474F);
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6D0);

  // Error Palette (Material 3 Standard)
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          primaryFixed: primaryFixed,
          onPrimaryFixed: onPrimaryFixed,
          secondary: secondary,
          onSecondary: Colors.white,
          secondaryContainer: secondaryContainer,
          onSecondaryContainer: onSecondaryContainer,
          onSecondaryFixedVariant: onSecondaryFixedVariant,
          tertiary: tertiary,
          onTertiary: Colors.white,
          tertiaryContainer: tertiaryContainer,
          onTertiaryContainer: onTertiaryContainer,
          tertiaryFixed: tertiaryFixed,
          tertiaryFixedDim: tertiaryFixedDim,
          error: error,
          onError: onError,
          errorContainer: errorContainer,
          onErrorContainer: onErrorContainer,
          surface: surface,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          outline: outline,
          outlineVariant: outlineVariant,
          surfaceContainerLowest: surfaceContainerLowest,
          surfaceContainerLow: surfaceContainerLow,
          surfaceContainer: surfaceContainer,
          surfaceContainerHigh: surfaceContainerHigh,
          surfaceContainerHighest: surfaceContainerHighest,
        );

    const smoothBuilder = _SmoothM3PageTransitionsBuilder();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: smoothBuilder,
          TargetPlatform.iOS: smoothBuilder,
          TargetPlatform.windows: smoothBuilder,
          TargetPlatform.macOS: smoothBuilder,
          TargetPlatform.linux: smoothBuilder,
          TargetPlatform.fuchsia: smoothBuilder,
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        iconColor: colorScheme.onSurfaceVariant,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        surfaceTintColor: Colors.transparent,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 76,
        indicatorColor: colorScheme.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onSecondaryContainer,
              size: 24,
            );
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
        }),
      ),
    );
  }
}
