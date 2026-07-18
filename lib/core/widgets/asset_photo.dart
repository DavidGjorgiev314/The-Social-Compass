import 'package:flutter/material.dart';

String _swapExtension(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return '${path.substring(0, path.length - 4)}.jpg';
  if (lower.endsWith('.jpg')) return '${path.substring(0, path.length - 4)}.png';
  if (lower.endsWith('.jpeg')) {
    return '${path.substring(0, path.length - 5)}.png';
  }
  return path;
}

Widget resilientAsset(
  String path, {
  double? width,
  double? height,
  int cacheWidth = 256,
  required Widget fallback,
}) {
  final alt = _swapExtension(path);
  return Image.asset(
    path,
    width: width,
    height: height,
    fit: BoxFit.cover,
    cacheWidth: cacheWidth,
    errorBuilder: (_, __, ___) => alt == path
        ? fallback
        : Image.asset(
            alt,
            width: width,
            height: height,
            fit: BoxFit.cover,
            cacheWidth: cacheWidth,
            errorBuilder: (_, __, ___) => fallback,
          ),
  );
}
