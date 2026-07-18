import 'package:flutter/material.dart';

class OsNotification {
  const OsNotification({
    required this.id,
    required this.appId,
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
    this.route,
  });

  final String id;
  final String appId;
  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  final String? route;
}
