import 'package:flutter/services.dart';

class HapticService {
  static bool enabled = true;

  static void light() {
    if (!enabled) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static void medium() {
    if (!enabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static void heavy() {
    if (!enabled) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  static void success() {
    if (!enabled) return;
    try {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.lightImpact();
      });
    } catch (_) {}
  }

  static void selection() {
    if (!enabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
