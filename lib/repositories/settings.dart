import "package:flutter/material.dart";
import "package:nxcalculator/models/setting.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:shared_preferences/shared_preferences.dart";

class SettingsRepository with ChangeNotifier {
  final _prefs = SharedPreferencesAsync();

  final Map<String, dynamic> _cache = {};

  bool get hasSameSeparators {
    return mapDecimalSeparator(get(decimalSeparator)) ==
        mapGroupingSeparator(get(groupingSeparator));
  }

  Future<void> load() async {
    for (final setting in allSettings) {
      final value = await setting.read(_prefs);
      _cache[setting.key] = value;
    }
  }

  Map<String, List<Setting>> getGrouped() {
    final Map<String, List<Setting>> grouped = {};

    for (final setting in allSettings) {
      grouped.putIfAbsent(setting.category.text, () => []).add(setting);
    }

    return grouped;
  }

  T get<T>(Setting<T> setting) {
    return _cache[setting.key] as T;
  }

  Future<void> set<T>(Setting<T> setting, T value) async {
    _cache[setting.key] = value;
    await setting.write(_prefs, value);
    notifyListeners();
  }
}
