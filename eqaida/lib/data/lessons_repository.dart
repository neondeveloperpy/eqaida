// lib/data/lessons_repository.dart
import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../models/letter_item_model.dart';

/// Local, offline lesson content. To add a lesson, append a LessonModel to
/// [all] - no new screens are needed.
class LessonsRepository {
  LessonsRepository._();

  // Look-alike families (used by the test engine).
  static const _boat = 'boat'; // ب ت ث ن ي
  static const _hook = 'hook'; // ج ح خ
  static const _short = 'short'; // د ذ ر ز و
  static const _heavy = 'heavy'; // ص ض ط ظ
  static const _loop = 'loop'; // ع غ ف ق
  static const _tall = 'tall'; // ا ل ك

  // Traditional right-to-left Qaida order.
  // Audio file names match the files in assets/audio/.
  static final List<LetterItem> _alphabet = [
    LetterItem(id: 'alif', symbol: '\u0627', name: 'Alif', audioFile: 'alif.mp3', color: Colors.red, family: _tall),
    LetterItem(id: 'baa', symbol: '\u0628', name: 'Baa', audioFile: 'ba.mp3', color: Colors.purple, family: _boat),
    LetterItem(id: 'taa', symbol: '\u062A', name: 'Taa', audioFile: 'taa.mp3', color: Colors.green, family: _boat),
    LetterItem(id: 'thaa', symbol: '\u062B', name: 'Thaa', audioFile: 'tha.mp3', color: Colors.orange, family: _boat),
    LetterItem(id: 'jeem', symbol: '\u062C', name: 'Jeem', audioFile: 'jeem.mp3', color: Colors.black, family: _hook),
    LetterItem(id: 'haa_h', symbol: '\u062D', name: 'Haa', audioFile: 'haa.mp3', color: Colors.deepPurple, family: _hook),
    LetterItem(id: 'khaa', symbol: '\u062E', name: 'Khaa', audioFile: 'khaa.mp3', color: Colors.teal, family: _hook),
    LetterItem(id: 'daal', symbol: '\u062F', name: 'Daal', audioFile: 'dal.mp3', color: Colors.pink, family: _short),
    LetterItem(id: 'zaal', symbol: '\u0630', name: 'Zaal', audioFile: 'dhal.mp3', color: Colors.pinkAccent, family: _short),
    LetterItem(id: 'raa', symbol: '\u0631', name: 'Raa', audioFile: 'raa.mp3', color: Colors.green.shade800, family: _short),
    LetterItem(id: 'zay', symbol: '\u0632', name: 'Zay', audioFile: 'jaa.mp3', color: Colors.cyan.shade700, family: _short),
    LetterItem(id: 'seen', symbol: '\u0633', name: 'Seen', audioFile: 'seen.mp3', color: Colors.deepOrange),
    LetterItem(id: 'sheen', symbol: '\u0634', name: 'Sheen', audioFile: 'sheen.mp3', color: Colors.black),
    LetterItem(id: 'saad', symbol: '\u0635', name: 'Saad', audioFile: 'saad.mp3', color: Colors.green.shade700, family: _heavy),
    LetterItem(id: 'daad', symbol: '\u0636', name: 'Daad', audioFile: 'dhaad.mp3', color: Colors.green.shade600, family: _heavy),
    LetterItem(id: 'toa', symbol: '\u0637', name: 'Toa', audioFile: 'toa.mp3', color: Colors.red.shade700, family: _heavy),
    LetterItem(id: 'zoa', symbol: '\u0638', name: 'Zoa', audioFile: 'dhaa.mp3', color: Colors.pink.shade700, family: _heavy),
    LetterItem(id: 'ain', symbol: '\u0639', name: 'Ain', audioFile: 'ain.mp3', color: Colors.blue.shade700, family: _loop),
    LetterItem(id: 'ghain', symbol: '\u063A', name: 'Ghain', audioFile: 'ghain.mp3', color: Colors.purple.shade700, family: _loop),
    LetterItem(id: 'faa', symbol: '\u0641', name: 'Faa', audioFile: 'faa.mp3', color: Colors.purple.shade500, family: _loop),
    LetterItem(id: 'qaaf', symbol: '\u0642', name: 'Qaaf', audioFile: 'qaaf.mp3', color: Colors.red.shade800, family: _loop),
    LetterItem(id: 'kaaf', symbol: '\u0643', name: 'Kaaf', audioFile: 'kaaf.mp3', color: Colors.orange.shade800, family: _tall),
    LetterItem(id: 'laam', symbol: '\u0644', name: 'Laam', audioFile: 'laam.mp3', color: Colors.black, family: _tall),
    LetterItem(id: 'meem', symbol: '\u0645', name: 'Meem', audioFile: 'meem.mp3', color: Colors.teal.shade700),
    LetterItem(id: 'noon', symbol: '\u0646', name: 'Noon', audioFile: 'noon.mp3', color: Colors.red.shade600, family: _boat),
    LetterItem(id: 'waw', symbol: '\u0648', name: 'Waw', audioFile: 'waw.mp3', color: Colors.blue.shade800, family: _short),
    LetterItem(id: 'haa_ha', symbol: '\u0647', name: 'Ha', audioFile: 'ha.mp3', color: Colors.purple.shade600),
    LetterItem(id: 'hamza', symbol: '\u0621', name: 'Hamza', audioFile: 'hamza.mp3', color: Colors.black87),
    LetterItem(id: 'yaa', symbol: '\u064A', name: 'Yaa', audioFile: 'yaa.mp3', color: Colors.red.shade700, family: _boat),
  ];

  static final List<LessonModel> all = [
    LessonModel(
      id: 1,
      title: 'Arabic Alphabets',
      arabicTitle: '\u0627\u0644\u062D\u0631\u0648\u0641 \u0627\u0644\u0639\u0631\u0628\u064A\u0629',
      items: _alphabet,
      testQuestionCount: 10,
    ),
    // Lessons 2-7 have no content yet -> shown as "Coming soon".
    // Add `items: [...]` to any of them and it becomes playable automatically.
    const LessonModel(id: 2, title: 'Fatha, Kasra & Damma'),
    const LessonModel(id: 3, title: 'Joined Letters'),
    const LessonModel(id: 4, title: 'Tanween'),
    const LessonModel(id: 5, title: 'Long Vowels (Madd)'),
    const LessonModel(id: 6, title: 'Sukoon & Shaddah'),
    const LessonModel(id: 7, title: 'Practice Reading'),
  ];

  static int get count => all.length;

  static LessonModel? byId(int id) {
    for (final l in all) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// The lesson after [id] that has content, or null.
  static LessonModel? nextAvailableAfter(int id) {
    for (final l in all) {
      if (l.id > id && l.isAvailable) return l;
    }
    return null;
  }

  /// Highest-numbered lesson the user may open right now.
  static LessonModel currentFor(int unlockedLesson) {
    LessonModel current = all.first;
    for (final l in all) {
      if (l.id <= unlockedLesson && l.isAvailable) current = l;
    }
    return current;
  }
}
