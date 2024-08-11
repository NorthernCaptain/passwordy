
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