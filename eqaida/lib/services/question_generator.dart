// lib/services/question_generator.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/lesson_model.dart';
import '../models/letter_item_model.dart';
import '../models/question_model.dart';

/// Builds a randomised quiz from ANY lesson's item list.
class QuestionGenerator {
  final Random _rng;
  QuestionGenerator({Random? random}) : _rng = random ?? Random();

  List<QuestionModel> generate(LessonModel lesson, {int? count}) {
    final items = lesson.items;
    if (items.length < 2) return const [];

    final total = min(count ?? lesson.testQuestionCount, items.length * 2);
    final targets = _targetQueue(items, total);

    // Cycle through the question types in a random order.
    final types = List<QuestionType>.from(QuestionType.values)..shuffle(_rng);

    final questions = <QuestionModel>[];
    for (var i = 0; i < total; i++) {
      final type = types[i % types.length];
      final target = targets[i];
      QuestionModel? q;
      switch (type) {
        case QuestionType.visualRecognition:
          q = _visual(target, items);
        case QuestionType.audioToSymbol:
          q = _audioToSymbol(target, items);
        case QuestionType.symbolToAudio:
          q = _symbolToAudio(target, items);
        case QuestionType.oddOneOut:
          q = _oddOneOut(items);
      }
      questions.add(q ?? _visual(target, items));
    }
    return questions;
  }

  // ---- question builders -------------------------------------------------

  QuestionModel _visual(LetterItem target, List<LetterItem> items) {
    final size = items.length >= 6 && _rng.nextBool() ? 6 : min(4, items.length);
    final options = _withDistractors(target, items, size);
    return QuestionModel(
      type: QuestionType.visualRecognition,
      prompt: 'Find the letter',
      target: target,
      options: options,
      correctIndex: options.indexOf(target),
      optionColors: _shuffledColors(options.length),
    );
  }

  QuestionModel _audioToSymbol(LetterItem target, List<LetterItem> items) {
    final options = _withDistractors(target, items, min(4, items.length));
    return QuestionModel(
      type: QuestionType.audioToSymbol,
      prompt: 'Listen and tap the letter',
      target: target,
      options: options,
      correctIndex: options.indexOf(target),
      optionColors: _shuffledColors(options.length),
    );
  }

  QuestionModel _symbolToAudio(LetterItem target, List<LetterItem> items) {
    final options = _withDistractors(target, items, min(4, items.length));
    return QuestionModel(
      type: QuestionType.symbolToAudio,
      prompt: 'Which sound matches this letter?',
      target: target,
      options: options,
      correctIndex: options.indexOf(target),
      optionColors: _shuffledColors(options.length),
    );
  }

  /// Three look-alike letters + one different. Returns null when the lesson
  /// has no family with at least 3 members and one outsider.
  QuestionModel? _oddOneOut(List<LetterItem> items) {
    final families = <String, List<LetterItem>>{};
    for (final it in items) {
      if (it.family != null) families.putIfAbsent(it.family!, () => []).add(it);
    }
    final usable = families.entries
        .where((e) => e.value.length >= 3 && items.any((i) => i.family != e.key))
        .toList();
    if (usable.isEmpty) return null;

    final chosen = usable[_rng.nextInt(usable.length)];
    final same = (List<LetterItem>.from(chosen.value)..shuffle(_rng)).take(3).toList();
    final outsiders = items.where((i) => i.family != chosen.key).toList();
    final odd = outsiders[_rng.nextInt(outsiders.length)];

    final options = [...same, odd]..shuffle(_rng);
    final neutral = Colors.blueGrey.shade600; // one colour: only shape matters
    return QuestionModel(
      type: QuestionType.oddOneOut,
      prompt: 'Which letter is different from the others?',
      target: odd,
      options: options,
      correctIndex: options.indexOf(odd),
      optionColors: List.filled(options.length, neutral),
    );
  }

  // ---- helpers -----------------------------------------------------------

  /// Every item is asked once before any repeats; no back-to-back repeats.
  List<LetterItem> _targetQueue(List<LetterItem> items, int total) {
    final queue = <LetterItem>[];
    while (queue.length < total) {
      final round = List<LetterItem>.from(items)..shuffle(_rng);
      if (queue.isNotEmpty && round.length > 1 && round.first == queue.last) {
        round.add(round.removeAt(0));
      }
      queue.addAll(round);
    }
    return queue.take(total).toList();
  }

  /// Target + (size-1) distractors, about half of them look-alikes,
  /// shuffled so the answer lands in a random position.
  List<LetterItem> _withDistractors(LetterItem target, List<LetterItem> items, int size) {
    final others = items.where((i) => i != target).toList()..shuffle(_rng);
    final needed = size - 1;

    final similar = target.family == null
        ? <LetterItem>[]
        : others.where((i) => i.family == target.family).toList();
    final picked = <LetterItem>[...similar.take((needed / 2).ceil())];
    for (final o in others) {
      if (picked.length >= needed) break;
      if (!picked.contains(o)) picked.add(o);
    }
    return [target, ...picked]..shuffle(_rng);
  }

  List<Color> _shuffledColors(int n) {
    final palette = List<Color>.from(AppTheme.choicePalette)..shuffle(_rng);
    return palette.take(n).toList();
  }
}
