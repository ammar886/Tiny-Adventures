import 'package:audioplayers/audioplayers.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';

/// Abstraction for offline sound-effect and animal-sound playback.
abstract class AudioService {
  String? get lastError;

  Future<void> playAsset(String assetPath);
  Future<void> playGentleChime();
  Future<void> playSoftTap();
  Future<void> stopAll();
  Future<void> setAppActive(bool isActive);
  Future<void> dispose();
}

/// Offline audio playback backed by `audioplayers`.
class AssetAudioService implements AudioService {
  AssetAudioService({
    required this._settingsRepository,
    AudioPlayer? player,
  })  : _player = player ?? AudioPlayer();

  static const String chimeAsset = 'audio/chime_gentle.wav';
  static const String tapAsset = 'audio/tap_soft.wav';

  final SettingsRepository _settingsRepository;
  final AudioPlayer _player;

  bool _isAppActive = true;
  bool _isDisposed = false;
  String? _lastError;

  @override
  String? get lastError => _lastError;

  @override
  Future<void> playAsset(String assetPath) async {
    if (_isDisposed || !_isAppActive) return;
    if (!_settingsRepository.settings.soundEnabled) return;

    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    }
  }

  @override
  Future<void> playGentleChime() => playAsset(chimeAsset);

  @override
  Future<void> playSoftTap() => playAsset(tapAsset);

  @override
  Future<void> stopAll() async {
    if (_isDisposed) return;
    try {
      await _player.stop();
    } catch (error) {
      _lastError = error.toString();
    }
  }

  @override
  Future<void> setAppActive(bool isActive) async {
    _isAppActive = isActive;
    if (!isActive) {
      await stopAll();
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      await _player.stop();
      await _player.dispose();
    } catch (_) {
      // Ignore platform disposal errors on teardown.
    }
  }
}
