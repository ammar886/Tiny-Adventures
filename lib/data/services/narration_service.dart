import 'package:flutter_tts/flutter_tts.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';

/// Abstraction for offline spoken narration prompts.
abstract class NarrationService {
  String? get lastError;

  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setAppActive(bool isActive);
  Future<void> dispose();
}

/// Offline text-to-speech narration backed by the device's built-in TTS engine.
class TtsNarrationService implements NarrationService {
  TtsNarrationService({
    required this._settingsRepository,
    FlutterTts? tts,
  })  : _tts = tts ?? FlutterTts();

  final SettingsRepository _settingsRepository;
  final FlutterTts _tts;

  bool _isInitialized = false;
  bool _isAppActive = true;
  bool _isDisposed = false;
  String? _lastError;

  @override
  String? get lastError => _lastError;

  Future<void> _ensureInitialized() async {
    if (_isInitialized || _isDisposed) return;
    _isInitialized = true;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.08);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(false);
    } catch (error) {
      _lastError = error.toString();
    }
  }

  @override
  Future<void> speak(String text) async {
    if (_isDisposed || !_isAppActive) return;
    if (!_settingsRepository.settings.narrationEnabled) return;
    if (text.trim().isEmpty) return;

    await _ensureInitialized();
    try {
      await _tts.stop();
      await _tts.speak(text);
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    }
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) return;
    try {
      await _tts.stop();
    } catch (error) {
      _lastError = error.toString();
    }
  }

  @override
  Future<void> setAppActive(bool isActive) async {
    _isAppActive = isActive;
    if (!isActive) {
      await stop();
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await stop();
  }
}
