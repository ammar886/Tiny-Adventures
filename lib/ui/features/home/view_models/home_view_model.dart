import 'package:flutter/foundation.dart';
import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';

enum HomeActivity {
  animalSounds,
  colorMatching,
  moveAndFind,
}

/// Manages home-screen greetings, mascot taps, and gentle session checks.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._audioService,
    required this._narrationService,
    required this._sessionRepository,
  });

  final AudioService _audioService;
  final NarrationService _narrationService;
  final SessionRepository _sessionRepository;

  bool _hasGreeted = false;
  String _greetingText = 'Hi friend! Let’s play!';
  String get greetingText => _greetingText;

  bool get shouldShowSessionEnding => _sessionRepository.isSessionComplete;

  Future<void> playWelcomeGreeting() async {
    if (_hasGreeted) return;
    _hasGreeted = true;
    await _narrationService.speak(
      'Hi friend! Welcome to Tiny Adventures. Pick a picture to play!',
    );
  }

  Future<void> onMascotTapped() async {
    _greetingText = 'Yay! Let’s explore together!';
    notifyListeners();
    await _audioService.playSoftTap();
    await _narrationService.speak('Hi there, little explorer! Ready to play?');
  }

  Future<void> onActivityCardTapped() async {
    await _audioService.playSoftTap();
  }
}
