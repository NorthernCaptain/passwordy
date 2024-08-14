
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

String generateId() {
  return uuid.v1();
}

extension AsExtension on Object? {
  X as<X>() => this as X;
  X? asOrNull<X>() {
    var self = this;
    return self is X ? self : null;
  }
}

extension ColorExtension on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromString(String colorString) {
    final buffer = StringBuffer();
    if (colorString.length == 6 || colorString.length == 7) buffer.write('ff');
    buffer.write(colorString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  bool isLightColor() {
    return computeLuminance() > 0.5;
  }
}

snackError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Theme.of(context).colorScheme.error,
    duration: const Duration(seconds: 3),
  ));
}

snackInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 3),
  ));
}