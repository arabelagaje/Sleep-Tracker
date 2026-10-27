import 'package:flutter/material.dart';

// Design tokens: colors for light and dark, read via context.colors.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg, surface, surface2, ink, ink2, muted, line;
  final Color accent, accentInk, onAccent, accentSoft, star, danger;
  final Color orbA, orbB, orbGlow, track;
  final List<Color> heat; // h0..h4
  final Color heatInkLo, heatInkHi, heatInk3;
  final Color toast, toastInk, toastAccent;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.ink2,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentInk,
    required this.onAccent,
    required this.accentSoft,
    required this.star,
    required this.danger,
    required this.orbA,
    required this.orbB,
    required this.orbGlow,
    required this.track,
    required this.heat,
    required this.heatInkLo,
    required this.heatInkHi,
    required this.heatInk3,
    required this.toast,
    required this.toastInk,
    required this.toastAccent,
  });

  static const light = AppColors(
    bg: Color(0xFFF6F5FC),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEFEDF8),
    ink: Color(0xFF1D1B33),
    ink2: Color(0xFF57537A),
    muted: Color(0xFFC9C5DF),
    line: Color(0xFFE2DFF0),
    accent: Color(0xFF5B4FD6),
    accentInk: Color(0xFF4A3FC4),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFE6E3FB),
    star: Color(0xFFE49A1C),
    danger: Color(0xFFC2334D),
    orbA: Color(0xFF7A6FF0),
    orbB: Color(0xFF4A3FC4),
    orbGlow: Color(0x475B4FD6),
    track: Color(0xFFEBE9F6),
    heat: [
      Color(0xFFEFEDF8),
      Color(0xFFDCD8FA),
      Color(0xFFB4ABF2),
      Color(0xFF7D70E3),
      Color(0xFF4A3FC4),
    ],
    heatInkLo: Color(0xFF1D1B33),
    heatInkHi: Color(0xFFFFFFFF),
    heatInk3: Color(0xFFFFFFFF),
    toast: Color(0xFF1D1B33),
    toastInk: Color(0xFFFFFFFF),
    toastAccent: Color(0xFFB8B0FF),
  );

  static const dark = AppColors(
    bg: Color(0xFF100F1E),
    surface: Color(0xFF1A1930),
    surface2: Color(0xFF232240),
    ink: Color(0xFFEEEDFA),
    ink2: Color(0xFFA6A2C8),
    muted: Color(0xFF3E3B62),
    line: Color(0xFF2C2A4A),
    accent: Color(0xFF8F86FF),
    accentInk: Color(0xFFA9A2FF),
    onAccent: Color(0xFF120F2E),
    accentSoft: Color(0xFF2A2752),
    star: Color(0xFFF5B742),
    danger: Color(0xFFFF7A8F),
    orbA: Color(0xFF3A3190),
    orbB: Color(0xFF1F1A5C),
    orbGlow: Color(0x4D8F86FF),
    track: Color(0xFF22213C),
    heat: [
      Color(0xFF1F1E38),
      Color(0xFF2E2A5C),
      Color(0xFF4A419A),
      Color(0xFF7A70E0),
      Color(0xFFB3ABFF),
    ],
    heatInkLo: Color(0xFFEEEDFA),
    heatInkHi: Color(0xFF120F2E),
    heatInk3: Color(0xFF120F2E),
    toast: Color(0xFFEEEDFA),
    toastInk: Color(0xFF100F1E),
    toastAccent: Color(0xFF4A3FC4),
  );

  // Calendar colour for a shade in 0–1, blended across heat[1]..heat[4].
  Color heatAt(double t) {
    final stops = heat.sublist(1);
    final x = t.clamp(0.0, 1.0) * (stops.length - 1);
    final i = x.floor().clamp(0, stops.length - 2);
    return Color.lerp(stops[i], stops[i + 1], x - i)!;
  }

  // Readable text on top of [bg].
  Color inkOn(Color bg) => bg.computeLuminance() > 0.3 ? const Color(0xFF1D1B33) : Colors.white;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme.fromSeed(seedColor: c.accent, brightness: brightness).copyWith(
    primary: c.accent,
    onPrimary: c.onAccent,
    surface: c.surface,
    onSurface: c.ink,
    error: c.danger,
  );
  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: c.bg,
    dividerColor: c.line,
    extensions: [c],
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.toast,
      contentTextStyle: TextStyle(color: c.toastInk, fontSize: 14, fontFamily: 'PlusJakartaSans'),
      actionTextColor: c.toastAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      showDragHandle: true,
      dragHandleColor: c.line,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: c.surface),
  );
}
