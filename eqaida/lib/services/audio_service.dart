// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

/// Single shared player so sounds never overlap.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();

  /// Plays assets/audio/[file]. Returns false if it could not be played
  /// (a missing file must never crash the app).
  Future<bool> play(String file) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('${AppConstants.audioDir}/$file'));
      return true;
    } catch (e) {
      debugPrint('AudioService: could not play $file ($e)');
      return false;
    }
  }

  /// Plays [file] and completes when it finishes (or after a safety timeout).
  Future<void> playAndWait(String file) async {
    final done = _player.onPlayerComplete.first;
    if (!await play(file)) return;
    await done.timeout(const Duration(seconds: 6), onTimeout: () {});
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }
}
