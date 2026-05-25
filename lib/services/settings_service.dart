import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool pushNotifications;
  final bool privateAccount;
  final bool showLocation;
  final bool showOnlineStatus;

  const AppSettings({
    this.pushNotifications = true,
    this.privateAccount = false,
    this.showLocation = true,
    this.showOnlineStatus = true,
  });

  AppSettings copyWith({
    bool? pushNotifications,
    bool? privateAccount,
    bool? showLocation,
    bool? showOnlineStatus,
  }) =>
      AppSettings(
        pushNotifications: pushNotifications ?? this.pushNotifications,
        privateAccount: privateAccount ?? this.privateAccount,
        showLocation: showLocation ?? this.showLocation,
        showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      );
}

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _kPush = 'settings_push';
  static const _kPrivate = 'settings_private';
  static const _kLocation = 'settings_location';
  static const _kOnlineStatus = 'settings_online_status';

  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = AppSettings(
      pushNotifications: prefs.getBool(_kPush) ?? true,
      privateAccount: prefs.getBool(_kPrivate) ?? false,
      showLocation: prefs.getBool(_kLocation) ?? true,
      showOnlineStatus: prefs.getBool(_kOnlineStatus) ?? true,
    );
    notifyListeners();
  }

  Future<void> setPushNotifications(bool v) async {
    _settings = _settings.copyWith(pushNotifications: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPush, v);
    notifyListeners();
  }

  Future<void> setPrivateAccount(bool v) async {
    _settings = _settings.copyWith(privateAccount: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrivate, v);
    notifyListeners();
  }

  Future<void> setShowLocation(bool v) async {
    _settings = _settings.copyWith(showLocation: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLocation, v);
    notifyListeners();
  }

  Future<void> setShowOnlineStatus(bool v) async {
    _settings = _settings.copyWith(showOnlineStatus: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnlineStatus, v);
    notifyListeners();
  }
}
