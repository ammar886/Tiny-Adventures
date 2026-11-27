import 'package:tiny_adventures/data/repositories/session_repository.dart';
import 'package:tiny_adventures/data/repositories/settings_repository.dart';
import 'package:tiny_adventures/data/services/audio_service.dart';
import 'package:tiny_adventures/data/services/narration_service.dart';
import 'package:tiny_adventures/data/services/storage_service.dart';

/// Dependency container for Tiny Adventures services and repositories.
class AppDependencies {
  AppDependencies({
    required this.settingsRepository,
    required this.audioService,
    required this.narrationService,
    required this.sessionRepository,
  });

  factory AppDependencies.createDefault() {
    final storageService = SharedPreferencesStorageService();
    final settingsRepository = SettingsRepository(
      storageService: storageService,
    );
    final audioService = AssetAudioService(
      settingsRepository: settingsRepository,
    );
    final narrationService = TtsNarrationService(
      settingsRepository: settingsRepository,
    );
    final sessionRepository = SessionRepository(
      settingsRepository: settingsRepository,
    );

    return AppDependencies(
      settingsRepository: settingsRepository,
      audioService: audioService,
      narrationService: narrationService,
      sessionRepository: sessionRepository,
    );
  }

  final SettingsRepository settingsRepository;
  final AudioService audioService;
  final NarrationService narrationService;
  final SessionRepository sessionRepository;

  Future<void> initialize() async {
    await settingsRepository.load();
    sessionRepository.start();
  }

  Future<void> dispose() async {
    sessionRepository.dispose();
    await audioService.dispose();
    await narrationService.dispose();
    settingsRepository.dispose();
  }
}
