// lib/core/constants/app_constants.dart

/// Named routes used across the app.
class AppRoutes {
  AppRoutes._();

  static const String auth = '/auth';
  static const String home = '/home';

  /// Arguments: `int` lessonId.
  static const String lesson = '/lesson';

  /// Arguments: `int` lessonId.
  static const String test = '/test';
}

/// App-wide constants (asset paths, fonts, API URLs, thresholds).
class AppConstants {
  AppConstants._();

  static const String appName = 'eQaida App';

  // Assets
  static const String audioDir = 'audio'; // AssetSource adds the 'assets/' prefix
  static const String loginImage = 'assets/images/login.png';
  static const String homeImage = 'assets/images/home.png';

  // Fonts
  static const String arabicFont = 'Amiri';

  // Learning rules
  static const int defaultPassScore = 70; // percent needed to unlock next lesson
  static const int defaultTestQuestions = 10;

  // Backend (used when AuthService is switched to FastAPI)
  static const String apiBaseUrl = 'http://10.0.2.2:8000'; // Android emulator -> host
}
