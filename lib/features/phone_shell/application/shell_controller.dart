import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/os_notification.dart';
import '../domain/phone_app.dart';

class ShellState {
  const ShellState({
    this.isLocked = true,
    this.openAppId,
    this.launchOrigin = Alignment.center,
    this.apps = const [],
    this.banners = const [],
  });

  final bool isLocked;
  final String? openAppId;
  final Alignment launchOrigin;
  final List<PhoneApp> apps;
  final List<OsNotification> banners;

  ShellState copyWith({
    bool? isLocked,
    Object? openAppId = _sentinel,
    Alignment? launchOrigin,
    List<PhoneApp>? apps,
    List<OsNotification>? banners,
  }) {
    return ShellState(
      isLocked: isLocked ?? this.isLocked,
      openAppId:
          openAppId == _sentinel ? this.openAppId : openAppId as String?,
      launchOrigin: launchOrigin ?? this.launchOrigin,
      apps: apps ?? this.apps,
      banners: banners ?? this.banners,
    );
  }

  static const Object _sentinel = Object();
}

class ShellController extends Notifier<ShellState> {
  @override
  ShellState build() => ShellState(apps: _defaultApps);

  void unlock() {
    if (state.isLocked) state = state.copyWith(isLocked: false);
  }

  void lock() => state = state.copyWith(isLocked: true, openAppId: null);

  void openApp(String id, {Alignment origin = Alignment.center}) {
    state = state.copyWith(openAppId: id, launchOrigin: origin);
  }

  void closeApp() => state = state.copyWith(openAppId: null);

  void pushNotification(OsNotification notification) {
    state = state.copyWith(banners: [...state.banners, notification]);
  }

  void dismissNotification(String id) {
    state = state.copyWith(
      banners: state.banners.where((n) => n.id != id).toList(),
    );
  }

  void setBadge(String appId, int count) {
    state = state.copyWith(
      apps: [
        for (final app in state.apps)
          if (app.id == appId) app.copyWith(badgeCount: count) else app,
      ],
    );
  }

  static const List<PhoneApp> _defaultApps = [
    PhoneApp(
      id: PhoneApps.pixelgram,
      label: 'Pixelgram',
      icon: Icons.camera_alt_rounded,
      gradient: [Color(0xFFFA7E1E), Color(0xFFD62976), Color(0xFF962FBF)],
    ),
    PhoneApp(
      id: PhoneApps.settings,
      label: 'Settings',
      icon: Icons.settings_rounded,
      gradient: [Color(0xFF6B7385), Color(0xFF3A4152)],
    ),
    PhoneApp(
      id: PhoneApps.camera,
      label: 'Camera',
      icon: Icons.photo_camera_rounded,
      gradient: [Color(0xFF2C3140), Color(0xFF171B26)],
    ),
    PhoneApp(
      id: PhoneApps.photos,
      label: 'Photos',
      icon: Icons.collections_rounded,
      gradient: [Color(0xFF43E0B8), Color(0xFF2C9C8A)],
    ),
    PhoneApp(
      id: PhoneApps.notes,
      label: 'Notes',
      icon: Icons.sticky_note_2_rounded,
      gradient: [Color(0xFFFFC15E), Color(0xFFE0972C)],
    ),
    PhoneApp(
      id: PhoneApps.clock,
      label: 'Clock',
      icon: Icons.access_time_filled_rounded,
      gradient: [Color(0xFF4C8DFF), Color(0xFF2C5AB0)],
    ),
  ];
}

final shellControllerProvider =
    NotifierProvider<ShellController, ShellState>(ShellController.new);
