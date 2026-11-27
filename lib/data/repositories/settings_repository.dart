import 'package:flutter/foundation.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';
import 'package:tiny_adventures/domain/models/parent_settings.dart';

/// Single source of truth for parent preferences and gentle local progress.
class SettingsRepository extends ChangeNotifier {
  SettingsRepository({required this._storageService});

  static const _sessionDurationKey = 'tiny_adventures_session_duration_min';
  static const _soundEnabledKey = 'tiny_adventures_sound_enabled';
  static const _narrationEnabledKey = 'tiny_adventures_narration_enabled';
  static const _exploredAnimalsKey = 'tiny_adventures_explored_animals';
  static const _colorRoundsKey = 'tiny_adventures_color_rounds';
  static const _movePromptsKey = 'tiny_adventures_move_prompts';

  final StorageService _storageService;

  ParentSettings _settings = const ParentSettings();
  ParentSettings get settings => _settings;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  String? _lastError;
  String? get lastError => _lastError;

  /// Loads persisted settings from local storage, falling back to safe defaults.
  Future<void> load() async {
    try {
      final duration = await _storageService.getInt(_sessionDurationKey);
      final sound = await _storageService.getBool(_soundEnabledKey);
      final narration = await _storageService.getBool(_narrationEnabledKey);
      final animals = await _storageService.getStringList(_exploredAnimalsKey);
      final colorRounds = await _storageService.getInt(_colorRoundsKey);
      final movePrompts = await _storageService.getInt(_movePromptsKey);

      _settings = ParentSettings(
        sessionDurationMinutes:
            duration ?? ParentSettings.defaultSessionDurationMinutes,
        soundEnabled: sound ?? true,
        narrationEnabled: narration ?? true,
        exploredAnimalIds: (animals ?? const <String>[]).toSet(),
        completedColorRounds: colorRounds ?? 0,
        completedMovePrompts: movePrompts ?? 0,
      );
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
      _settings = const ParentSettings();
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setSessionDurationMinutes(int minutes) async {
    if (_settings.sessionDurationMinutes == minutes) return;
    _settings = _settings.copyWith(sessionDurationMinutes: minutes);
    notifyListeners();
    await _safeWrite(
      () => _storageService.setInt(_sessionDurationKey, minutes),
    );
  }

  Future<void> setSoundEnabled(bool enabled) async {
    if (_settings.soundEnabled == enabled) return;
    _settings = _settings.copyWith(soundEnabled: enabled);
    notifyListeners();
    await _safeWrite(
      () => _storageService.setBool(_soundEnabledKey, enabled),
    );
  }

  Future<void> setNarrationEnabled(bool enabled) async {
    if (_settings.narrationEnabled == enabled) return;
    _settings = _settings.copyWith(narrationEnabled: enabled);
    notifyListeners();
    await _safeWrite(
      () => _storageService.setBool(_narrationEnabledKey, enabled),
    );
  }

  Future<void> recordAnimalExplored(String animalId) async {
    if (_settings.exploredAnimalIds.contains(animalId)) return;
    final updated = Set<String>.from(_settings.exploredAnimalIds)..add(animalId);
    _settings = _settings.copyWith(exploredAnimalIds: updated);
    notifyListeners();
    await _safeWrite(
      () => _storageService.setStringList(
        _exploredAnimalsKey,
        updated.toList()..sort(),
      ),
    );
  }

  Future<void> incrementColorRounds() async {
    final next = _settings.completedColorRounds + 1;
    _settings = _settings.copyWith(completedColorRounds: next);
    notifyListeners();
    await _safeWrite(() => _storageService.setInt(_colorRoundsKey, next));
  }

  Future<void> incrementMovePrompts() async {
    final next = _settings.completedMovePrompts + 1;
    _settings = _settings.copyWith(completedMovePrompts: next);
    notifyListeners();
    await _safeWrite(() => _storageService.setInt(_movePromptsKey, next));
  }

  /// Clears local child exploration counts while preserving parent preferences.
  Future<void> resetProgress() async {
    _settings = _settings.copyWith(
      exploredAnimalIds: const <String>{},
      completedColorRounds: 0,
      completedMovePrompts: 0,
    );
    notifyListeners();
    await _safeWrite(() async {
      await _storageService.setStringList(_exploredAnimalsKey, const []);
      await _storageService.setInt(_colorRoundsKey, 0);
      await _storageService.setInt(_movePromptsKey, 0);
    });
  }

  Future<void> _safeWrite(Future<void> Function() action) async {
    try {
      await action();
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    }
  }
}
