import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';
import 'package:tiny_adventures/ui/features/parent_controls/views/parent_gate_dialog.dart';
import 'package:tiny_adventures/ui/features/parent_controls/views/parent_settings_screen.dart';

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
  int stopCount = 0;

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
  Future<void> setAppActive(bool isActive) async {}

  @override
  Future<void> stopAll() async => stopCount++;
}

class _SpyNarrationService implements NarrationService {
  int stopCount = 0;

  @override
  String? get lastError => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> setAppActive(bool isActive) async {}

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async => stopCount++;
}

void main() {
  testWidgets('ParentGateDialog ignores quick tap and unlocks after 2s hold',
      (tester) async {
    bool? gateResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  gateResult = await showParentGateDialog(context);
                },
                child: const Text('Open Gate'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Gate'));
    await tester.pumpAndSettle();
    expect(find.text('Parents Only'), findsOneWidget);

    // Quick accidental toddler tap should not unlock
    final lockFinder = find.byKey(const ValueKey('parent_gate_hold_button'));
    await tester.tap(lockFinder);
    await tester.pump(const Duration(milliseconds: 300));
    expect(gateResult, isNull);
    expect(find.text('Parents Only'), findsOneWidget);

    // Sustained 2-second parent press-and-hold unlocks
    final gesture = await tester.startGesture(tester.getCenter(lockFinder));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(gateResult, isTrue);
  });

  testWidgets('ParentSettingsScreen updates preferences and resets progress',
      (tester) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final settings = SettingsRepository(storageService: _InMemoryStorage());
    await settings.load();
    await settings.recordAnimalExplored('dog');
    await settings.incrementColorRounds();

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
        home: ParentSettingsScreen(dependencies: deps),
      ),
    );

    expect(find.text('Parent Controls'), findsOneWidget);
    expect(find.textContaining('Animals discovered: 1 of 6'), findsOneWidget);

    await tester.tap(find.text('15 min'));
    await tester.pump();
    expect(settings.settings.sessionDurationMinutes, 15);

    await tester.tap(find.text('Sound Effects & Animal Sounds'));
    await tester.pump();
    expect(settings.settings.soundEnabled, isFalse);
    expect(audio.stopCount, 1);

    await tester.tap(find.text('Spoken Narration'));
    await tester.pump();
    expect(settings.settings.narrationEnabled, isFalse);
    expect(tts.stopCount, 1);

    await tester.ensureVisible(find.text('Reset Local Progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset Local Progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(settings.settings.exploredAnimalIds, isEmpty);
    expect(settings.settings.completedColorRounds, 0);

    await tester.scrollUntilVisible(find.text('About & Privacy'), 200);
    expect(find.textContaining('100% offline'), findsOneWidget);
  });
}
