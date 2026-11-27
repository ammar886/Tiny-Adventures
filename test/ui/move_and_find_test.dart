import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/data/local/move_prompt_catalog.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';
import 'package:tiny_adventures/ui/features/move_and_find/views/move_and_find_screen.dart';

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
  test('MovePromptCatalog includes all 5 physical prompts', () {
    expect(MovePromptCatalog.all.length, 5);
    final texts = MovePromptCatalog.all.map((p) => p.promptText).toList();
    expect(texts, contains('Can you clap your hands?'));
    expect(texts, contains('Can you jump like a frog?'));
    expect(texts, contains('Can you find something blue?'));
    expect(texts, contains('Can you wave hello?'));
    expect(texts, contains('Can you touch your nose?'));
  });

  testWidgets('MoveAndFindScreen celebrates completion and advances prompt',
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
        home: MoveAndFindScreen(
          dependencies: deps,
          onSessionEnded: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Can you clap your hands?'), findsOneWidget);
    expect(find.text('I did it!'), findsOneWidget);

    await tester.tap(find.text('I did it!'));
    await tester.pump();

    expect(audio.chimeCount, 1);
    expect(find.text('Clap, clap, clap! Great job!'), findsOneWidget);
    expect(settings.settings.completedMovePrompts, 1);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Can you jump like a frog?'), findsOneWidget);
  });
}
