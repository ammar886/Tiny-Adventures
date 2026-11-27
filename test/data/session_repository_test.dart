import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';

class _StubStorageService implements StorageService {
  final Map<String, Object> _store = {};

  @override
  Future<bool?> getBool(String key) async => _store[key] as bool?;

  @override
  Future<int?> getInt(String key) async => _store[key] as int?;

  @override
  Future<List<String>?> getStringList(String key) async =>
      _store[key] as List<String>?;

  @override
  Future<void> setBool(String key, bool value) async => _store[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _store[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _store[key] = value;
}

void main() {
  group('SessionRepository', () {
    test('completes session after configured minutes and pauses cleanly',
        () async {
      final settings = SettingsRepository(
        storageService: _StubStorageService(),
      );
      await settings.load();
      await settings.setSessionDurationMinutes(5);

      final session = SessionRepository(settingsRepository: settings);
      addTearDown(session.dispose);

      expect(session.isSessionComplete, isFalse);

      session.advanceBy(const Duration(minutes: 4));
      expect(session.isSessionComplete, isFalse);

      session.pause();
      session.advanceBy(const Duration(minutes: 2));
      expect(session.isSessionComplete, isFalse);

      session.resume();
      session.advanceBy(const Duration(minutes: 1));
      expect(session.isSessionComplete, isTrue);

      session.startNewSession();
      expect(session.isSessionComplete, isFalse);
      expect(session.elapsed, Duration.zero);
    });

    test('never completes when session limit is disabled (0 min)', () async {
      final settings = SettingsRepository(
        storageService: _StubStorageService(),
      );
      await settings.load();
      await settings.setSessionDurationMinutes(0);

      final session = SessionRepository(settingsRepository: settings);
      addTearDown(session.dispose);

      session.advanceBy(const Duration(hours: 2));
      expect(session.isSessionComplete, isFalse);
    });
  });
}
