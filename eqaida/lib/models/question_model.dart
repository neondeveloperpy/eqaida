// lib/models/question_model.dart
import 'package:flutter/material.dart';
import 'letter_item_model.dart';

enum QuestionType {
  /// "Find the letter Baa" – grid of letters, colours shuffled.
  visualRecognition,

  /// Sound plays automatically – tap the matching letter.
  audioToSymbol,

  /// Letter shown – tap the matching sound.
  symbolToAudio,

  /// Several look-alike letters and one different – tap the odd one.
  oddOneOut,
}

class QuestionModel {
  final QuestionType type;
  final String prompt;
  final LetterItem target; // the item being asked about (the odd one for oddOneOut)
  final List<LetterItem> options;
  final int correctIndex;
  final List<Color> optionColors;

  const QuestionModel({
    required this.type,
    required this.prompt,
    required this.target,
    required this.options,
    required this.correctIndex,
    required this.optionColors,
  });

  LetterItem get answer => options[correctIndex];
  bool isCorrect(int index) => index == correctIndex;
}
