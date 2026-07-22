import 'package:flutter/material.dart';

import '../../gallery/presentation/gallery_app.dart';
import '../../pixelgram/presentation/pixelgram_app.dart';
import '../../settings_app/presentation/settings_app.dart';
import '../domain/phone_app.dart';
import 'widgets/placeholder_app.dart';

Widget buildAppScreen(PhoneApp app) {
  switch (app.id) {
    case PhoneApps.pixelgram:
      return const PixelgramApp();
    case PhoneApps.settings:
      return const SettingsApp();
    case PhoneApps.photos:
      return const GalleryApp();
    default:
      return PlaceholderApp(app: app);
  }
}
