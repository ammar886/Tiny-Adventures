import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';
import 'package:tiny_adventures/ui/features/animal_sounds/views/animal_sounds_screen.dart';

class _InMemoryStorage implements StorageService {
  final Map<String, Object> _data = {};

  @override
  Future<bool?> getBool(String key) async => _data[key] as bool?;

  @override
  Future<int?> getInt(String key) async => _data[key] as int?;

  @override
  Future<List<String>?> getStringList(String key) async =>
      _data[key] as List<String>?;

  @override
  Future<void> setBool(String key, bool value) async => _data[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _data[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _data[key] = value;
}

class _SpyAudioService implements AudioService {
  final List<String> playedAssets = [];

  @override
  String? get lastError => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async => playedAssets.add(assetPath);

  @override
  Future<void> playGentleChime() async {}

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
  testWidgets('AnimalSoundsScreen shows all 6 animals and plays sound on tap',
      (tester) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

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

    await tester.pumpWidget(
      MaterialApp(
        home: AnimalSoundsScreen(
          dependencies: deps,
          onSessionEnded: () {},
        ),
      ),
    );
    await tester.pump();

    for (final name in ['Dog', 'Cat', 'Cow', 'Duck', 'Lion', 'Elephant']) {
      expect(find.text(name), findsOneWidget);
    }

    await tester.tap(find.text('Dog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Dog says Woof!'), findsOneWidget);
    expect(tts.spoken, contains('Dog'));
    expect(audio.playedAssets, contains('audio/dog.wav'));
    expect(settings.settings.exploredAnimalIds, contains('dog'));
  });
}
