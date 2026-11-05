// lib/models/letter_item_model.dart
import 'package:flutter/material.dart';

/// One learnable symbol (letter, harakat mark, word...) inside a lesson.
class LetterItem {
  final String id; // unique, stable (e.g. 'alif')
  final String symbol; // what is drawn on screen
  final String name; // transliterated name shown under the symbol
  final String audioFile; // file inside assets/audio/
  final Color color; // traditional Qaida colour for the lesson view

  /// Letters sharing a family look alike (e.g. the "boat" family ب ت ث ن ي).
  /// Used to build tricky distractors and "odd one out" questions.
  final String? family;

  const LetterItem({
    required this.id,
    required this.symbol,
    required this.name,
    required this.audioFile,
    required this.color,
    this.family,
  });

  @override
  bool operator ==(Object other) => other is LetterItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
