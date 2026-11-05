import 'dart:io';
import 'dart:math';

import 'package:eqaida/data/lessons_repository.dart';
import 'package:eqaida/models/question_model.dart';
import 'package:eqaida/services/question_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lesson = LessonsRepository.byId(1)!;

  test('every lesson item points to an existing audio file', () {
    for (final item in lesson.items) {
      expect(File('assets/audio/${item.audioFile}').existsSync(), isTrue,
          reason: '${item.name} -> ${item.audioFile} is missing');
    }
  });

  test('item ids and symbols are unique', () {
    expect(lesson.items.map((i) => i.id).toSet().length, lesson.items.length);
    expect(lesson.items.map((i) => i.symbol).toSet().length, lesson.items.length);
  });

  test('generated questions are valid for many random seeds', () {
    for (var seed = 0; seed < 200; seed++) {
      final qs = QuestionGenerator(random: Random(seed)).generate(lesson);
      expect(qs.length, lesson.testQuestionCount);
      for (final q in qs) {
        expect(q.options.toSet().length, q.options.length, reason: 'duplicate options');
        expect(q.optionColors.length, q.options.length);
        if (q.type != QuestionType.oddOneOut) {
          expect(q.answer, q.target);
        } else {
          expect(q.options.length, 4);
        }
      }
    }
  });
}
