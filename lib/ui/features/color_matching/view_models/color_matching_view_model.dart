import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:tiny_adventures/data/local/color_catalog.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/domain/models/color_challenge.dart';

/// Manages Color Matching rounds with gentle feedback and zero penalty.
class ColorMatchingViewModel extends ChangeNotifier {
  ColorMatchingViewModel({
    required this._audioService,
    required this._narrationService,
    required this._settingsRepository,
    required this._sessionRepository,
    math.Random? random,
  }) : _random = random ?? math.Random() {
    _colorOrder = List<LearningColor>.from(LearningColor.values)..shuffle(_random);
    _challenge = ColorCatalog.buildChallengeFor(
      _colorOrder[_colorIndex],
      random: _random,
    );
  }

  final AudioService _audioService;
  final NarrationService _narrationService;
  final SettingsRepository _settingsRepository;
  final SessionRepository _sessionRepository;
  final math.Random _random;

  late final List<LearningColor> _colorOrder;
  int _colorIndex = 0;

  late ColorChallenge _challenge;
  ColorChallenge get challenge => _challenge;

  String? _selectedOptionId;
  String? get selectedOptionId => _selectedOptionId;

  bool _isMatched = false;
  bool get isMatched => _isMatched;

  String? _feedbackText;
  String? get feedbackText => _feedbackText;

  bool _shouldEndSession = false;
  bool get shouldEndSession => _shouldEndSession;

  bool _isDisposed = false;

  Future<void> start() async {
    await _narrationService.speak(_challenge.promptText);
  }

  Future<void> replayPrompt() async {
    await _narrationService.speak(_challenge.promptText);
  }

  Future<void> onOptionTapped(ColorObjectItem option) async {
    if (_isMatched || _isDisposed) return;

    _selectedOptionId = option.id;

    if (option.color == _challenge.targetColor) {
      _isMatched = true;
      _feedbackText = 'Yes! ${option.spokenPhrase}!';
      notifyListeners();

      await _settingsRepository.incrementColorRounds();
      await _audioService.playGentleChime();
      await _narrationService.speak('Yes! ${option.spokenPhrase}!');

      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (_isDisposed) return;

      if (_sessionRepository.isSessionComplete) {
        _shouldEndSession = true;
        notifyListeners();
        return;
      }

      _advanceToNextChallenge();
    } else {
      _feedbackText =
          'That is ${option.spokenPhrase.toLowerCase()}. Let’s look for ${_challenge.targetColor.name}!';
      notifyListeners();

      await _audioService.playSoftTap();
      await _narrationService.speak(
        'That is ${option.spokenPhrase}. Can you find ${_challenge.targetColor.name}?',
      );
    }
  }

  void _advanceToNextChallenge() {
    _colorIndex = (_colorIndex + 1) % _colorOrder.length;
    _challenge = ColorCatalog.buildChallengeFor(
      _colorOrder[_colorIndex],
      random: _random,
    );
    _selectedOptionId = null;
    _isMatched = false;
    _feedbackText = null;
    notifyListeners();
    _narrationService.speak(_challenge.promptText);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _audioService.stopAll();
    _narrationService.stop();
    super.dispose();
  }
}
