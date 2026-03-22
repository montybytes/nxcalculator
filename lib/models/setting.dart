import "package:flutter/widgets.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:shared_preferences/shared_preferences.dart";

enum NumpadShape { rounded, circular, mixed }

enum NumpadDensity { comfy, normal, dense }

enum GroupingSeparator { comma, dot, space, system }

enum DecimalSeparator { dot, comma, system }

enum Category {
  appearance("appearance"),
  fonts("fonts"),
  formatting("formatting"),
  functionality("functionality"),
  extra("extra");

  const Category(this.text);

  final String text;
}

class Setting<T> {
  final String key;
  final Category category;
  final Future<T> Function(SharedPreferencesAsync prefs) read;
  final Future<void> Function(SharedPreferencesAsync prefs, dynamic value)
  write;
  final Widget Function(
    SettingsRepository repo,
    dynamic value,
    ShapeBorder shape,
  )
  buildTile;

  const Setting({
    required this.key,
    required this.category,
    required this.read,
    required this.write,
    required this.buildTile,
  });
}
