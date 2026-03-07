import 'package:flutter_riverpod/flutter_riverpod.dart';

// Immutable snapshot of current app settings
class SettingsState {
  final bool notificationsEnabled;
  final bool nearbyAlertsEnabled;

  const SettingsState({
    this.notificationsEnabled = false,
    this.nearbyAlertsEnabled = false,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? nearbyAlertsEnabled,
  }) =>
      SettingsState(
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        nearbyAlertsEnabled: nearbyAlertsEnabled ?? this.nearbyAlertsEnabled,
      );
}

// Notifier that handles mutations to app settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleNotifications(bool value) =>
      state = state.copyWith(notificationsEnabled: value);

  void toggleNearbyAlerts(bool value) =>
      state = state.copyWith(nearbyAlertsEnabled: value);
}

// Provider exposing the SettingsNotifier
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
    (_) => SettingsNotifier());
