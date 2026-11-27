import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';
import 'package:tiny_adventures/domain/models/parent_settings.dart';

class _InMemoryStorageService implements StorageService {
  final Map<String, Object> _store = {};
  bool shouldThrowOnRead = false;

  @override
  Future<bool?> getBool(String key) async {
    if (shouldThrowOnRead) throw StateError('read failure');
    return _store[key] as bool?;
  }

  @override
  Future<int?> getInt(String key) async {
    if (shouldThrowOnRead) throw StateError('read failure');
    return _store[key] as int?;
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    if (shouldThrowOnRead) throw StateError('read failure');
    return (_store[key] as List<String>?)?.toList();
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _store[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _store[key] = value;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _store[key] = value.toList();
  }
}

void main() {
  group('SettingsRepository', () {
    test('loads default settings when storage is empty', () async {
      final repo = SettingsRepository(
        storageService: _InMemoryStorageService(),
      );

      await repo.load();

      expect(repo.isLoaded, isTrue);
      expect(repo.lastError, isNull);
      expect(repo.settings, const ParentSettings());
    });

    test('falls back safely when storage read fails', () async {
      final storage = _InMemoryStorageService()..shouldThrowOnRead = true;
      final repo = SettingsRepository(storageService: storage);

      await repo.load();

      expect(repo.isLoaded, isTrue);
      expect(repo.lastError, isNotNull);
      expect(repo.settings, const ParentSettings());
    });

    test('persists parent toggles and progress, and resets progress only',
        () async {
      final storage = _InMemoryStorageService();
      final repo = SettingsRepository(storageService: storage);
      await repo.load();

      await repo.setSessionDurationMinutes(15);
      await repo.setSoundEnabled(false);
      await repo.setNarrationEnabled(false);
      await repo.recordAnimalExplored('dog');
      await repo.incrementColorRounds();
      await repo.incrementMovePrompts();

      final reloaded = SettingsRepository(storageService: storage);
      await reloaded.load();
      expect(reloaded.settings.sessionDurationMinutes, 15);
      expect(reloaded.settings.soundEnabled, isFalse);
      expect(reloaded.settings.narrationEnabled, isFalse);
      expect(reloaded.settings.exploredAnimalIds, {'dog'});
      expect(reloaded.settings.completedColorRounds, 1);
      expect(reloaded.settings.completedMovePrompts, 1);

      await reloaded.resetProgress();
      expect(reloaded.settings.exploredAnimalIds, isEmpty);
      expect(reloaded.settings.completedColorRounds, 0);
      expect(reloaded.settings.completedMovePrompts, 0);
      expect(reloaded.settings.sessionDurationMinutes, 15);
      expect(reloaded.settings.soundEnabled, isFalse);
    });
  });
}
