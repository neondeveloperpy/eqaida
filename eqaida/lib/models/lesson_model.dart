// lib/models/lesson_model.dart
import '../core/constants/app_constants.dart';
import 'letter_item_model.dart';

class LessonModel {
  final int id;
  final String title;
  final String arabicTitle;
  final List<LetterItem> items;
  final int passScore;
  final int testQuestionCount;

  /// Set this for lessons with a unique mechanic (e.g. a connecting-letters
  /// puzzle). When non-null, "Take a Test" opens this route instead of the
  /// universal test. The route receives the lessonId as its argument.
  final String? customTestRoute;

  const LessonModel({
    required this.id,
    required this.title,
    this.arabicTitle = '',
    this.items = const [],
    this.passScore = AppConstants.defaultPassScore,
    this.testQuestionCount = AppConstants.defaultTestQuestions,
    this.customTestRoute,
  });

  /// Lessons without content yet are shown as "Coming soon".
  bool get isAvailable => items.isNotEmpty;
}
