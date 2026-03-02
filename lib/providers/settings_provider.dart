import 'package:flutter_riverpod/legacy.dart';

// Immutable snapshot of current app settings
class SettingsState {
  final bool notificationsEnabled;

  const SettingsState({this.notificationsEnabled = false});

  SettingsState copyWith({bool? notificationsEnabled}) => SettingsState(
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
      );
}

// Notifier that handles mutations to app settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  // Toggle location-based notification preference on or off
  void toggleNotifications(bool value) =>
      state = state.copyWith(notificationsEnabled: value);
}

// Provider exposing the SettingsNotifier
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
        (_) => SettingsNotifier());