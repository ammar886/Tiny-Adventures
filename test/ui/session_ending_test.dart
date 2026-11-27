import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';
import 'package:tiny_adventures/ui/features/session_ending/views/session_ending_screen.dart';

class _InMemoryStorage implements StorageService {
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

class _SpyAudioService implements AudioService {
  int chimeCount = 0;

  @override
  String? get lastError => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> playGentleChime() async => chimeCount++;

  @override
  Future<void> playSoftTap() async {}

  @override
  Future<void> setAppActive(bool isActive) async {}

  @override
  Future<void> stopAll() async {}
}

class _SpyNarrationService implements NarrationService {
  final List<String> spoken = [];

  @override
  String? get lastError => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> setAppActive(bool isActive) async {}

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async {}
}

void main() {
  testWidgets(
      'SessionEndingScreen displays warm ending message and offline play idea',
      (tester) async {
    final settings = SettingsRepository(storageService: _InMemoryStorage());
    await settings.load();
    final audio = _SpyAudioService();
    final tts = _SpyNarrationService();
    final deps = AppDependencies(
      settingsRepository: settings,
      audioService: audio,
      narrationService: tts,
      sessionRepository: SessionRepository(settingsRepository: settings),
    );
    addTearDown(deps.dispose);

    var parentTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SessionEndingScreen(
          dependencies: deps,
          onParentUnlockedNewSession: () => parentTapped = true,
          random: math.Random(0),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Great adventure!'), findsOneWidget);
    expect(find.text('Let’s go play together!'), findsOneWidget);
    expect(audio.chimeCount, 1);
    expect(tts.spoken.single, contains('Great adventure!'));

    await tester.tap(find.text('Parents: Start a new session'));
    await tester.pump();
    expect(parentTapped, isTrue);
  });
}
