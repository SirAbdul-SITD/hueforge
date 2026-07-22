import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/color_info.dart';
import 'package:flutter/material.dart';

class SavedService extends ChangeNotifier {
  static const _key = 'hf_saved_v1';
  List<Color> _saved = [];
  SharedPreferences? _prefs;

  List<Color> get saved => _saved;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getStringList(_key) ?? [];
    _saved = raw
        .map((s) => parseHex(s))
        .whereType<Color>()
        .toList();
    notifyListeners();
  }

  Future<void> add(Color c) async {
    final hex = ColorInfo(c).hexString;
    _saved.removeWhere((existing) => ColorInfo(existing).hexString == hex);
    _saved.insert(0, c);
    if (_saved.length > 24) _saved = _saved.sublist(0, 24);
    await _persist();
    notifyListeners();
  }

  Future<void> removeAt(int i) async {
    _saved.removeAt(i);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final raw = _saved.map((c) => ColorInfo(c).hexString).toList();
    await _prefs!.setStringList(_key, raw);
  }
}
