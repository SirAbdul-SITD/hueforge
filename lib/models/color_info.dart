import 'dart:math' as math;
import 'package:flutter/material.dart';

class ColorInfo {
  final Color color;
  ColorInfo(this.color);

  int get r => (color.r * 255).round();
  int get g => (color.g * 255).round();
  int get b => (color.b * 255).round();

  String get hexString {
    return '#${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  String get rgbString => 'rgb($r, $g, $b)';

  HSLColor get hsl => HSLColor.fromColor(color);
  HSVColor get hsv => HSVColor.fromColor(color);

  String get hslString {
    final h = hsl;
    return 'hsl(${h.hue.round()}, ${(h.saturation * 100).round()}%, '
        '${(h.lightness * 100).round()}%)';
  }

  String get hsvString {
    final h = hsv;
    return 'hsv(${h.hue.round()}, ${(h.saturation * 100).round()}%, '
        '${(h.value * 100).round()}%)';
  }

  /// Relative luminance per the WCAG 2.x formula:
  /// https://www.w3.org/WAI/GL/wiki/Relative_luminance
  double get relativeLuminance {
    double linearize(double c) =>
        c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * linearize(color.r) +
        0.7152 * linearize(color.g) +
        0.0722 * linearize(color.b);
  }
}

/// WCAG contrast ratio between two colors, always in [1.0, 21.0].
double contrastRatio(Color a, Color b) {
  final la = ColorInfo(a).relativeLuminance;
  final lb = ColorInfo(b).relativeLuminance;
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

enum WcagLevel { fail, aaLarge, aa, aaa }

/// Classifies a contrast ratio per WCAG 2.x thresholds. Normal text needs
/// 4.5:1 for AA and 7:1 for AAA; large text (>=18pt, or >=14pt bold) needs
/// 3:1 for AA and 4.5:1 for AAA.
WcagLevel wcagLevelFor(double ratio, {bool largeText = false}) {
  if (largeText) {
    if (ratio >= 4.5) return WcagLevel.aaa;
    if (ratio >= 3.0) return WcagLevel.aa;
    return WcagLevel.fail;
  }
  if (ratio >= 7.0) return WcagLevel.aaa;
  if (ratio >= 4.5) return WcagLevel.aa;
  if (ratio >= 3.0) return WcagLevel.aaLarge;
  return WcagLevel.fail;
}

Color? parseHex(String input) {
  var s = input.trim().replaceAll('#', '');
  if (s.length == 3) {
    s = s.split('').map((c) => '$c$c').join();
  }
  if (s.length != 6) return null;
  final value = int.tryParse(s, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}
