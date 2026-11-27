import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/data/local/color_catalog.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';
import 'package:tiny_adventures/domain/models/color_challenge.dart';
import 'package:tiny_adventures/ui/features/color_matching/view_models/color_matching_view_model.dart';
import 'package:tiny_adventures/ui/features/color_matching/views/color_matching_screen.dart';

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
  int tapCount = 0;

  @override
  String? get lastError => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> playGentleChime() async => chimeCount++;

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

void main() {
  test('ColorCatalog generates 3 distinct colors per challenge for all 6 colors',
      () {
    for (final color in LearningColor.values) {
      final challenge = ColorCatalog.buildChallengeFor(
        color,
        random: math.Random(1),
      );
      expect(challenge.options.length, 3);
      expect(challenge.options.map((o) => o.color).toSet().length, 3);
      expect(challenge.options.any((o) => o.color == color), isTrue);
    }
  });

  testWidgets('ColorMatchingScreen celebrates correct tap and advances',
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
        home: ColorMatchingScreen(
          dependencies: deps,
          onSessionEnded: () {},
          random: math.Random(42),
        ),
      ),
    );
    await tester.pump();

    final vm = ColorMatchingViewModel(
      audioService: audio,
      narrationService: tts,
      settingsRepository: settings,
      sessionRepository: deps.sessionRepository,
      random: math.Random(42),
    );
    addTearDown(vm.dispose);

    final firstPrompt = vm.challenge.promptText;
    final targetOption = vm.challenge.options
        .firstWhere((o) => o.color == vm.challenge.targetColor);
    final distractorOption = vm.challenge.options
        .firstWhere((o) => o.color != vm.challenge.targetColor);

    expect(find.text(firstPrompt), findsOneWidget);

    await tester.tap(find.text(distractorOption.name));
    await tester.pump();
    expect(audio.tapCount, 1);
    expect(audio.chimeCount, 0);

    await tester.tap(find.text(targetOption.name));
    await tester.pump();
    expect(audio.chimeCount, 1);
    expect(find.text('Yes! ${targetOption.spokenPhrase}!'), findsOneWidget);
    expect(settings.settings.completedColorRounds, 1);

    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text(firstPrompt), findsNothing);
  });
}
