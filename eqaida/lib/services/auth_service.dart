// lib/services/auth_service.dart
//
// The UI only talks to this class. Today it uses SharedPreferences; later the
// bodies can call the FastAPI backend (AppConstants.apiBaseUrl) instead and
// no screen needs to change.
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();

  static const String _keyEmail = 'user_email';
  static const String _keyUnlockedLesson = 'unlocked_lesson';
  static const String _scorePrefix = 'score_lesson_';

  static Future<void> saveUserSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    if (!prefs.containsKey(_keyUnlockedLesson)) {
      await prefs.setInt(_keyUnlockedLesson, 1);
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_keyEmail) ?? '').isNotEmpty;
  }

  static Future<int> getUnlockedLesson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUnlockedLesson) ?? 1;
  }

  /// Saves the best score for the lesson. The next lesson is unlocked only
  /// when [passed] is true.
  static Future<void> completeLessonTest(
    int lessonId,
    int score, {
    required bool passed,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final previousBest = prefs.getInt('$_scorePrefix$lessonId') ?? 0;
    if (score > previousBest) {
      await prefs.setInt('$_scorePrefix$lessonId', score);
    }

    if (passed) {
      final unlocked = prefs.getInt(_keyUnlockedLesson) ?? 1;
      if (lessonId >= unlocked) {
        await prefs.setInt(_keyUnlockedLesson, lessonId + 1);
      }
    }
  }

  static Future<int?> getTestScore(int lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_scorePrefix$lessonId');
  }

  /// Current user profile + progress, or null when logged out.
  static Future<UserModel?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    if (email == null || email.isEmpty) return null;

    final scores = <int, int>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_scorePrefix)) {
        final id = int.tryParse(key.substring(_scorePrefix.length));
        final value = prefs.getInt(key);
        if (id != null && value != null) scores[id] = value;
      }
    }
    return UserModel(
      email: email,
      highestUnlockedLesson: prefs.getInt(_keyUnlockedLesson) ?? 1,
      testScores: scores,
    );
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove only account data; device settings (e.g. theme_mode) stay.
    final keys = prefs.getKeys().where(
      (k) => k == _keyEmail || k == _keyUnlockedLesson || k.startsWith(_scorePrefix),
    );
    for (final k in keys.toList()) {
      await prefs.remove(k);
    }
  }
}
