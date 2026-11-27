import 'package:flutter/foundation.dart';

/// Persistent local settings and gentle exploration progress.
@immutable
class ParentSettings {
  const ParentSettings({
    this.sessionDurationMinutes = defaultSessionDurationMinutes,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.exploredAnimalIds = const <String>{},
    this.completedColorRounds = 0,
    this.completedMovePrompts = 0,
  });

  static const int defaultSessionDurationMinutes = 10;
  static const List<int> availableDurationsMinutes = <int>[5, 10, 15, 0];

  /// Session length in minutes; 0 disables automatic gentle ending.
  final int sessionDurationMinutes;
  final bool soundEnabled;
  final bool narrationEnabled;
  final Set<String> exploredAnimalIds;
  final int completedColorRounds;
  final int completedMovePrompts;

  bool get hasSessionLimit => sessionDurationMinutes > 0;

  ParentSettings copyWith({
    int? sessionDurationMinutes,
    bool? soundEnabled,
    bool? narrationEnabled,
    Set<String>? exploredAnimalIds,
    int? completedColorRounds,
    int? completedMovePrompts,
  }) {
    return ParentSettings(
      sessionDurationMinutes:
          sessionDurationMinutes ?? this.sessionDurationMinutes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      narrationEnabled: narrationEnabled ?? this.narrationEnabled,
      exploredAnimalIds: exploredAnimalIds ?? this.exploredAnimalIds,
      completedColorRounds: completedColorRounds ?? this.completedColorRounds,
      completedMovePrompts: completedMovePrompts ?? this.completedMovePrompts,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParentSettings &&
        other.sessionDurationMinutes == sessionDurationMinutes &&
        other.soundEnabled == soundEnabled &&
        other.narrationEnabled == narrationEnabled &&
        setEquals(other.exploredAnimalIds, exploredAnimalIds) &&
        other.completedColorRounds == completedColorRounds &&
        other.completedMovePrompts == completedMovePrompts;
  }

  @override
  int get hashCode => Object.hash(
        sessionDurationMinutes,
        soundEnabled,
        narrationEnabled,
        Object.hashAllUnordered(exploredAnimalIds),
        completedColorRounds,
        completedMovePrompts,
      );
}
