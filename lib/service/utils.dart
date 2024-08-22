
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passwordy/service/log.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

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

class BarrierWaiter {
  Completer<void> _completer = Completer<void>();
  int _nowRunning = 0;

  void start() {
    _nowRunning++;
  }

  bool isSafe() {
    return _nowRunning == 0;
  }

  // Method for the producer to signal completion
  void signalCompletion() {
    _nowRunning = max(0, _nowRunning - 1);
    if (_nowRunning == 0) _completer.complete();
  }

  // Method for consumers to await completion
  Future<void> awaitCompletion() async {
    if (_nowRunning == 0) return;
    await _completer.future;
  }

  Future<T> safely<T>(Future<T> Function() action) async {
    await awaitCompletion();
    return action();
  }

  // Reset the synchronization state
  void reset() {
    if (_nowRunning == 0) {
      _completer = Completer<void>();
    } else {
      lg?.e("Barrier reset called while still running: $_nowRunning");
    }
  }

  Future<T> run<T>(Future<T> Function() action) async {
    start();
    try {
      return await action();
    } finally {
      signalCompletion();
    }
  }
}