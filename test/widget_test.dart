import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_adventures/app/app.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';

class _FakeStorageService implements StorageService {
  @override
  Future<bool?> getBool(String key) async => null;

  @override
  Future<int?> getInt(String key) async => null;

  @override
  Future<List<String>?> getStringList(String key) async => null;

  @override
  Future<void> setBool(String key, bool value) async {}

  @override
  Future<void> setInt(String key, int value) async {}

  @override
  Future<void> setStringList(String key, List<String> value) async {}
}

class _LifecycleAudioService implements AudioService {
  bool isActive = true;

  @override
  String? get lastError => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> playGentleChime() async {}

  @override
  Future<void> playSoftTap() async {}

  @override
  Future<void> setAppActive(bool active) async => isActive = active;

  @override
  Future<void> stopAll() async {}
}

class _LifecycleNarrationService implements NarrationService {
  bool isActive = true;

  @override
  String? get lastError => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> setAppActive(bool active) async => isActive = active;

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}

void main() {
  testWidgets('App pauses audio, narration, and session when backgrounded',
      (tester) async {
    final settingsRepo = SettingsRepository(
      storageService: _FakeStorageService(),
    );
    await settingsRepo.load();

    final audio = _LifecycleAudioService();
    final narration = _LifecycleNarrationService();
    final session = SessionRepository(settingsRepository: settingsRepo);
    final dependencies = AppDependencies(
      settingsRepository: settingsRepo,
      audioService: audio,
      narrationService: narration,
      sessionRepository: session,
    );
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(TinyAdventuresApp(dependencies: dependencies));
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(audio.isActive, isFalse);
    expect(narration.isActive, isFalse);
    expect(session.isPaused, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(audio.isActive, isTrue);
    expect(narration.isActive, isTrue);
    expect(session.isPaused, isFalse);

    session.pause();
  });
}
