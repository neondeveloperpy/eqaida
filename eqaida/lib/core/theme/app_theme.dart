// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Custom colour tokens that Material's ColorScheme doesn't cover.
/// Change them here and every screen follows (light + dark).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color lessonCard;
  final Color lessonCardLocked;
  final Color onLessonCard;
  final Color action; // amber action buttons
  final Color onAction;
  final Color banner;
  final Color onBanner;
  final Color success;
  final Color danger;

  const AppColors({
    required this.lessonCard,
    required this.lessonCardLocked,
    required this.onLessonCard,
    required this.action,
    required this.onAction,
    required this.banner,
    required this.onBanner,
    required this.success,
    required this.danger,
  });

  static const AppColors light = AppColors(
    lessonCard: Color(0xFF9EE359),
    lessonCardLocked: Color(0xFFE0E0E0),
    onLessonCard: Colors.black,
    action: Color(0xFFFFD54F),
    onAction: Colors.black87,
    banner: Color(0xFFA5D6A7),
    onBanner: Colors.black87,
    success: Color(0xFF2E7D32),
    danger: Color(0xFFC62828),
  );

  static const AppColors dark = AppColors(
    lessonCard: Color(0xFF4C7A26),
    lessonCardLocked: Color(0xFF2C2C2C),
    onLessonCard: Colors.white,
    action: Color(0xFFFFC107),
    onAction: Colors.black87,
    banner: Color(0xFF2E5B3A),
    onBanner: Colors.white,
    success: Color(0xFF66BB6A),
    danger: Color(0xFFEF5350),
  );

  @override
  AppColors copyWith({
    Color? lessonCard,
    Color? lessonCardLocked,
    Color? onLessonCard,
    Color? action,
    Color? onAction,
    Color? banner,
    Color? onBanner,
    Color? success,
    Color? danger,
  }) =>
      AppColors(
        lessonCard: lessonCard ?? this.lessonCard,
        lessonCardLocked: lessonCardLocked ?? this.lessonCardLocked,
        onLessonCard: onLessonCard ?? this.onLessonCard,
        action: action ?? this.action,
        onAction: onAction ?? this.onAction,
        banner: banner ?? this.banner,
        onBanner: onBanner ?? this.onBanner,
        success: success ?? this.success,
        danger: danger ?? this.danger,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      lessonCard: Color.lerp(lessonCard, other.lessonCard, t)!,
      lessonCardLocked: Color.lerp(lessonCardLocked, other.lessonCardLocked, t)!,
      onLessonCard: Color.lerp(onLessonCard, other.onLessonCard, t)!,
      action: Color.lerp(action, other.action, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      banner: Color.lerp(banner, other.banner, t)!,
      onBanner: Color.lerp(onBanner, other.onBanner, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static const Color seed = Colors.teal;

  /// Colours used to shuffle quiz choices so a child can't memorise
  /// "the green box on the left". All are readable on light and dark cards.
  static const List<Color> choicePalette = [
    Color(0xFFE53935), // red
    Color(0xFF8E24AA), // purple
    Color(0xFF1E88E5), // blue
    Color(0xFF43A047), // green
    Color(0xFFFB8C00), // orange
    Color(0xFF00897B), // teal
    Color(0xFFD81B60), // pink
    Color(0xFF6D4C41), // brown
  ];

  static ThemeData get light => _build(Brightness.light, AppColors.light);
  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppConstants.appFont,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFFAFAFA)
          : const Color(0xFF121212),
      extensions: [colors],
    );
  }

  /// Letters with very dark colours (e.g. black) vanish in dark mode,
  /// and very light ones vanish in light mode. Adjust only when needed.
  static Color letterColor(BuildContext context, Color base) {
    final bg = Theme.of(context).colorScheme.surface;
    final contrast = (base.computeLuminance() - bg.computeLuminance()).abs();
    if (contrast < 0.25) return Theme.of(context).colorScheme.onSurface;
    return base;
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
