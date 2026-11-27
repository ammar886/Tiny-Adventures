import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:tiny_adventures/data/local/move_prompt_catalog.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/domain/models/move_prompt.dart';

/// Manages real-world Move & Find prompts without camera or sensor dependencies.
class MoveAndFindViewModel extends ChangeNotifier {
  MoveAndFindViewModel({
    required this._audioService,
    required this._narrationService,
    required this._settingsRepository,
    required this._sessionRepository,
    math.Random? random,
  }) : _prompts = List<MovePrompt>.from(MovePromptCatalog.all) {
    if (random != null) {
      _prompts.shuffle(random);
    }
  }

  final AudioService _audioService;
  final NarrationService _narrationService;
  final SettingsRepository _settingsRepository;
  final SessionRepository _sessionRepository;
  final List<MovePrompt> _prompts;

  int _index = 0;
  MovePrompt get currentPrompt => _prompts[_index];

  bool _isCelebrating = false;
  bool get isCelebrating => _isCelebrating;

  bool _shouldEndSession = false;
  bool get shouldEndSession => _shouldEndSession;

  bool _isDisposed = false;

  Future<void> start() async {
    await _narrationService.speak(currentPrompt.promptText);
  }

  Future<void> replayPrompt() async {
    await _narrationService.speak(currentPrompt.promptText);
  }

  Future<void> completePrompt() async {
    if (_isCelebrating || _isDisposed) return;

    _isCelebrating = true;
    notifyListeners();

    await _settingsRepository.incrementMovePrompts();
    await _audioService.playGentleChime();
    await _narrationService.speak(currentPrompt.encouragementText);

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (_isDisposed) return;

    if (_sessionRepository.isSessionComplete) {
      _shouldEndSession = true;
      notifyListeners();
      return;
    }

    _index = (_index + 1) % _prompts.length;
    _isCelebrating = false;
    notifyListeners();
    await _narrationService.speak(currentPrompt.promptText);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _audioService.stopAll();
    _narrationService.stop();
    super.dispose();
  }
}
