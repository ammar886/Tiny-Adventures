import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';

/// Tracks gentle session pacing without countdown pressure or streaks.
class SessionRepository extends ChangeNotifier {
  SessionRepository({
    required this._settingsRepository,
    this.tickInterval = const Duration(seconds: 1),
  }) {
    _settingsRepository.addListener(_onSettingsChanged);
  }

  final SettingsRepository _settingsRepository;
  final Duration tickInterval;

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isPaused = false;
  bool _isDisposed = false;

  Duration get elapsed => _elapsed;
  bool get isPaused => _isPaused;

  bool get isSessionComplete {
    final limitMinutes = _settingsRepository.settings.sessionDurationMinutes;
    if (limitMinutes <= 0) return false;
    return _elapsed >= Duration(minutes: limitMinutes);
  }

  void start() {
    if (_isDisposed) return;
    _isPaused = false;
    _timer?.cancel();
    _timer = Timer.periodic(tickInterval, (_) => advanceBy(tickInterval));
  }

  void pause() {
    _isPaused = true;
    _timer?.cancel();
    _timer = null;
  }

  void resume() {
    if (_isDisposed) return;
    if (!_isPaused && _timer != null) return;
    start();
  }

  void startNewSession() {
    _elapsed = Duration.zero;
    notifyListeners();
    start();
  }

  @visibleForTesting
  void advanceBy(Duration delta) {
    if (_isDisposed || _isPaused) return;
    if (!_settingsRepository.settings.hasSessionLimit) return;

    final wasComplete = isSessionComplete;
    _elapsed += delta;
    if (!wasComplete && isSessionComplete) {
      notifyListeners();
    }
  }

  void _onSettingsChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    _settingsRepository.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
