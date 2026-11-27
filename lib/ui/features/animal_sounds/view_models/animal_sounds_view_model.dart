import 'package:flutter/foundation.dart';
import 'package:tiny_adventures/data/local/animal_catalog.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/domain/models/animal_item.dart';

/// Manages Animal Sounds discovery state without endless reward loops.
class AnimalSoundsViewModel extends ChangeNotifier {
  AnimalSoundsViewModel({
    required this._audioService,
    required this._narrationService,
    required this._settingsRepository,
    required this._sessionRepository,
  });

  final AudioService _audioService;
  final NarrationService _narrationService;
  final SettingsRepository _settingsRepository;
  final SessionRepository _sessionRepository;

  List<AnimalItem> get animals => AnimalCatalog.all;

  AnimalItem? _activeAnimal;
  AnimalItem? get activeAnimal => _activeAnimal;

  final Map<AnimalId, int> _pulseCounters = {};
  int pulseCountFor(AnimalId id) => _pulseCounters[id] ?? 0;

  bool get shouldShowSessionEnding => _sessionRepository.isSessionComplete;

  int _tapGeneration = 0;
  bool _isDisposed = false;

  Future<void> start() async {
    await _narrationService.speak('Tap an animal friend to hear its sound!');
  }

  Future<void> replayPrompt() async {
    final current = _activeAnimal;
    if (current != null) {
      await _narrationService.speak('${current.name}! ${current.soundText}');
    } else {
      await start();
    }
  }

  Future<void> onAnimalTapped(AnimalItem animal) async {
    final gen = ++_tapGeneration;
    _activeAnimal = animal;
    _pulseCounters[animal.id] = (_pulseCounters[animal.id] ?? 0) + 1;
    notifyListeners();

    await _settingsRepository.recordAnimalExplored(animal.id.name);

    final narrationOn = _settingsRepository.settings.narrationEnabled;
    if (narrationOn) {
      await _narrationService.speak(animal.name);
      await Future<void>.delayed(const Duration(milliseconds: 520));
    }

    if (_isDisposed || gen != _tapGeneration) return;
    await _audioService.playAsset(animal.audioAsset);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _audioService.stopAll();
    _narrationService.stop();
    super.dispose();
  }
}
