import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_adventures/app/app.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';
import 'package:tiny_adventures/ui/features/home/view_models/home_view_model.dart';
import 'package:tiny_adventures/ui/features/home/views/home_screen.dart';

class _TestStorage implements StorageService {
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
  int tapCount = 0;

  @override
  String? get lastError => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> playGentleChime() async {}

  @override
  Future<void> playSoftTap() async => tapCount++;

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

Future<({AppDependencies deps, _SpyAudioService audio, _SpyNarrationService tts})>
    _buildTestDeps() async {
  final settings = SettingsRepository(storageService: _TestStorage());
  await settings.load();
  final audio = _SpyAudioService();
  final tts = _SpyNarrationService();
  final deps = AppDependencies(
    settingsRepository: settings,
    audioService: audio,
    narrationService: tts,
    sessionRepository: SessionRepository(settingsRepository: settings),
  );
  return (deps: deps, audio: audio, tts: tts);
}

void main() {
  testWidgets('HomeScreen displays greeting, mascot, and three activity cards',
      (tester) async {
    final bundle = await _buildTestDeps();
    addTearDown(bundle.deps.dispose);

    HomeActivity? selected;
    var parentOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          dependencies: bundle.deps,
          onSelectActivity: (activity) => selected = activity,
          onOpenParentControls: () => parentOpened = true,
          onSessionEnded: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Tiny Adventures'), findsOneWidget);
    expect(find.text('Animal Sounds'), findsOneWidget);
    expect(find.text('Color Matching'), findsOneWidget);
    expect(find.text('Move & Find'), findsOneWidget);
    expect(find.text('Parents'), findsOneWidget);
    expect(bundle.tts.spoken, isNotEmpty);

    await tester.tap(find.text('Animal Sounds'));
    await tester.pump();
    expect(selected, HomeActivity.animalSounds);
    expect(bundle.audio.tapCount, 1);

    await tester.tap(find.text('Parents'));
    await tester.pump();
    expect(parentOpened, isTrue);
  });

  testWidgets('App renders HomeScreen as initial screen', (tester) async {
    final bundle = await _buildTestDeps();
    addTearDown(bundle.deps.dispose);

    await tester.pumpWidget(TinyAdventuresApp(dependencies: bundle.deps));
    await tester.pump();

    expect(find.text('Animal Sounds'), findsOneWidget);
    expect(find.text('Color Matching'), findsOneWidget);
    expect(find.text('Move & Find'), findsOneWidget);
  });
}
