import 'package:flutter/foundation.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/domain/models/parent_settings.dart';

/// ViewModel for the Parent Controls screen.
class ParentSettingsViewModel extends ChangeNotifier {
  ParentSettingsViewModel({
    required this._settingsRepository,
    required this._sessionRepository,
    required this._audioService,
    required this._narrationService,
  }) {
    _settingsRepository.addListener(_onSettingsChanged);
  }

  final SettingsRepository _settingsRepository;
  final SessionRepository _sessionRepository;
  final AudioService _audioService;
  final NarrationService _narrationService;

  ParentSettings get settings => _settingsRepository.settings;

  Future<void> setSessionDurationMinutes(int minutes) async {
    await _settingsRepository.setSessionDurationMinutes(minutes);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _settingsRepository.setSoundEnabled(enabled);
    if (!enabled) {
      await _audioService.stopAll();
    }
  }

  Future<void> setNarrationEnabled(bool enabled) async {
    await _settingsRepository.setNarrationEnabled(enabled);
    if (!enabled) {
      await _narrationService.stop();
    }
  }

  Future<void> resetProgress() async {
    await _settingsRepository.resetProgress();
  }

  void startNewSession() {
    _sessionRepository.startNewSession();
  }

  void _onSettingsChanged() => notifyListeners();

  @override
  void dispose() {
    _settingsRepository.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
