import "package:flutter/material.dart" hide Switch, Checkbox;
import "package:nxcalculator/models/setting.dart";
import "package:nxcalculator/screens/settings/licenses.dart";
import "package:nxcalculator/screens/settings/privacy_policy.dart";
import "package:nxcalculator/services/screen_timeout.dart";
import "package:nxcalculator/widgets/slide_page_route.dart";
import "package:nxdesign/fonts.dart";
import "package:nxdesign/widgets.dart"
    show MultiSetting, MultiSettingData, NxIcon, Switch;
import "package:shared_preferences/shared_preferences.dart";

final allSettings = <Setting>[
  themeMode,
  swapDecimalZero,
  hideCalcText,
  preferIconsToText,
  preferBottomToolbar,
  numpadButtonShape,
  numpadDensity,
  equationResultFont,
  numpadFont,
  groupingSeparator,
  decimalSeparator,
  preventDuplicateHistory,
  startExtended,
  swipeUpHistory,
  keepScreenAwake,
  disableHaptics,
  showLicenses,
  showPrivacyPolicy,
];

Future<void> _writeToStorageHelper(
  SharedPreferencesAsync prefs,
  String key,
  dynamic value,
) async {
  if (value is ThemeMode) {
    await prefs.setString(key, value.name);
  } else if (value is NumpadShape) {
    await prefs.setString(key, value.name);
  } else if (value is NumpadDensity) {
    await prefs.setString(key, value.name);
  } else if (value is GroupingSeparator) {
    await prefs.setString(key, value.name);
  } else if (value is DecimalSeparator) {
    await prefs.setString(key, value.name);
  } else if (value is bool) {
    await prefs.setBool(key, value);
  } else if (value is String) {
    await prefs.setString(key, value);
  }
}

// App Appearance Settings

final Setting<ThemeMode> themeMode = Setting(
  key: "theme_mode",
  category: Category.appearance,
  read: (prefs) async {
    final value = await prefs.getString(themeMode.key);
    return switch (value) {
      "light" => ThemeMode.light,
      "dark" => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  },
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, themeMode.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildMultiSettingTile(
      shape: shape,
      title: "App Theme Mode",
      currentValue: value,
      selectableValues: const [
        MultiSettingData(label: "System", data: ThemeMode.system),
        MultiSettingData(label: "Light", data: ThemeMode.light),
        MultiSettingData(label: "Dark", data: ThemeMode.dark),
      ],
      onUpdate: (value) async => await repo.set(themeMode, value),
    );
  },
);

final Setting<bool> swapDecimalZero = Setting(
  key: "swap_decimal_zero",
  category: Category.appearance,
  read: (prefs) async => await prefs.getBool(swapDecimalZero.key) ?? false,
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, swapDecimalZero.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildBooleanTile(
      shape: shape,
      title: "Swap Decimal & Zero",
      currentValue: value as bool,
      onUpdate: () async => await repo.set(swapDecimalZero, !value),
    );
  },
);

final Setting<bool> preferBottomToolbar = Setting(
  key: "prefer_bottom_toolbar",
  category: Category.appearance,
  read: (prefs) async => await prefs.getBool(preferIconsToText.key) ?? false,
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, preferIconsToText.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildBooleanTile(
      shape: shape,
      title: "Toolbar Above Numpad",
      description: "Move history and mode buttons directly above the numpad",
      currentValue: value as bool,
      onUpdate: () async => await repo.set(preferBottomToolbar, !value),
    );
  },
);

final Setting<bool> hideCalcText = Setting(
  key: "hide_calc_text",
  category: Category.appearance,
  read: (prefs) async => await prefs.getBool(hideCalcText.key) ?? false,
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, hideCalcText.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildBooleanTile(
      shape: shape,
      title: "Hide 'Calculator' Text",
      currentValue: value as bool,
      onUpdate: () async => await repo.set(hideCalcText, !value),
    );
  },
);

final Setting<bool> preferIconsToText = Setting(
  key: "prefer_icon_to_text",
  category: Category.appearance,
  read: (prefs) async => await prefs.getBool(preferIconsToText.key) ?? false,
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, preferIconsToText.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildBooleanTile(
      shape: shape,
      title: "Prefer Icon For Clear Button",
      currentValue: value as bool,
      onUpdate: () async => await repo.set(preferIconsToText, !value),
    );
  },
);

final Setting<NumpadShape> numpadButtonShape = Setting(
  key: "button_shape",
  category: Category.appearance,
  read: (prefs) async {
    final value = await prefs.getString(numpadButtonShape.key);
    return switch (value) {
      "rounded" => NumpadShape.rounded,
      "circular" => NumpadShape.circular,
      _ => NumpadShape.mixed,
    };
  },
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, numpadButtonShape.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildMultiSettingTile(
      shape: shape,
      title: "Numpad Button Shape",
      currentValue: value,
      selectableValues: const [
        MultiSettingData(data: NumpadShape.circular, label: "Circle"),
        MultiSettingData(data: NumpadShape.rounded, label: "Rounded"),
        MultiSettingData(data: NumpadShape.mixed, label: "Mixed"),
      ],
      onUpdate: (value) async => await repo.set(numpadButtonShape, value),
    );
  },
);

final Setting<NumpadDensity> numpadDensity = Setting(
  key: "numpad_density",
  category: Category.appearance,
  read: (prefs) async {
    final value = await prefs.getString(numpadDensity.key);
    return switch (value) {
      "comfy" => NumpadDensity.comfy,
      "dense" => NumpadDensity.dense,
      _ => NumpadDensity.normal,
    };
  },
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, numpadDensity.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildMultiSettingTile(
      shape: shape,
      title: "Numpad Button Density",
      currentValue: value,
      selectableValues: const [
        MultiSettingData(data: NumpadDensity.comfy, label: "Comfy"),
        MultiSettingData(data: NumpadDensity.normal, label: "Normal"),
        MultiSettingData(data: NumpadDensity.dense, label: "Dense"),
      ],
      onUpdate: (value) async => await repo.set(numpadDensity, value),
    );
  },
);

// Fonts Settings

final Setting<String> equationResultFont = Setting(
  key: "equation_result_font",
  category: Category.fonts,
  read: (prefs) async {
    return await prefs.getString(equationResultFont.key) ?? NxFonts.fontInter;
  },
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, equationResultFont.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildExpandableTile(
      shape: shape,
      title: "Equation & Result Font",
      currentValue: value,
      selectableValues: [
        NxFonts.fontInter,
        NxFonts.fontLettera,
        NxFonts.fontNDot,
        NxFonts.fontNType,
      ],
      onUpdate: (value) async => await repo.set(equationResultFont, value),
    );
  },
);

final Setting<String> numpadFont = Setting(
  key: "numpad_font",
  category: Category.fonts,
  read: (prefs) async {
    return await prefs.getString(numpadFont.key) ?? NxFonts.fontNType;
  },
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, numpadFont.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildExpandableTile(
      shape: shape,
      title: "Numpad Font",
      currentValue: value,
      selectableValues: [
        NxFonts.fontInter,
        NxFonts.fontLettera,
        NxFonts.fontNDot,
        NxFonts.fontNType,
      ],
      onUpdate: (value) async => await repo.set(numpadFont, value),
    );
  },
);

// Formatting Settings

final Setting<GroupingSeparator> groupingSeparator = Setting(
  key: "grouping_separator",
  category: Category.formatting,
  read: (prefs) async {
    final value = await prefs.getString(groupingSeparator.key);
    return switch (value) {
      "comma" => GroupingSeparator.comma,
      "dot" => GroupingSeparator.dot,
      "space" => GroupingSeparator.space,
      _ => GroupingSeparator.system,
    };
  },
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, groupingSeparator.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildMultiSettingTile(
      shape: shape,
      title: "Grouping Separator",
      currentValue: value,
      selectableValues: const [
        MultiSettingData(data: GroupingSeparator.system, label: "System"),
        MultiSettingData(data: GroupingSeparator.comma, label: "Comma"),
        MultiSettingData(data: GroupingSeparator.dot, label: "Dot"),
        MultiSettingData(data: GroupingSeparator.space, label: "Space"),
      ],
      onUpdate: (value) async => await repo.set(groupingSeparator, value),
    );
  },
);

final Setting<DecimalSeparator> decimalSeparator = Setting(
  key: "decimal_separator",
  category: Category.formatting,
  read: (prefs) async {
    final value = await prefs.getString(decimalSeparator.key);
    return switch (value) {
      "comma" => DecimalSeparator.comma,
      "dot" => DecimalSeparator.dot,
      _ => DecimalSeparator.system,
    };
  },
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, decimalSeparator.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildMultiSettingTile(
      shape: shape,
      title: "Decimal Separator",
      currentValue: value,
      selectableValues: const [
        MultiSettingData(data: DecimalSeparator.system, label: "System"),
        MultiSettingData(data: DecimalSeparator.comma, label: "Comma"),
        MultiSettingData(data: DecimalSeparator.dot, label: "Dot"),
      ],
      onUpdate: (value) async => await repo.set(decimalSeparator, value),
    );
  },
);

// Functionality Settings

final Setting<bool> preventDuplicateHistory = Setting(
  key: "prevent_duplicate_history",
  category: Category.functionality,
  read: (prefs) async {
    return await prefs.getBool(preventDuplicateHistory.key) ?? false;
  },
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, preventDuplicateHistory.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildBooleanTile(
      shape: shape,
      title: "Prevent Duplicate Simultaneous Calculation",
      description:
          "Prevent calculator from adding the same calculation to the history if the equation and result are the same as the last calculation",
      currentValue: value as bool,
      onUpdate: () async {
        await repo.set(preventDuplicateHistory, !value);
      },
    );
  },
);

final Setting<bool> startExtended = Setting(
  key: "start_extended",
  category: Category.functionality,
  read: (prefs) async => await prefs.getBool(startExtended.key) ?? false,
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, startExtended.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildBooleanTile(
      shape: shape,
      title: "Start in Scientific Mode",
      description: "Choose whether to always start in Scientific Mode",
      currentValue: value as bool,
      onUpdate: () async {
        await repo.set(startExtended, !value);
      },
    );
  },
);

final Setting<bool> swipeUpHistory = Setting(
  key: "swipe_up_history",
  category: Category.functionality,
  read: (prefs) async => await prefs.getBool(swipeUpHistory.key) ?? false,
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, swipeUpHistory.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildBooleanTile(
      shape: shape,
      title: "Swipe Up To Show History",
      description: "Use a quick swipe-up gesture on the numpad to show history",
      currentValue: value as bool,
      onUpdate: () async {
        await repo.set(swipeUpHistory, !value);
      },
    );
  },
);

final Setting<bool> keepScreenAwake = Setting(
  key: "keep_screen_awake",
  category: Category.functionality,
  read: (prefs) async => await prefs.getBool(keepScreenAwake.key) ?? false,
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, keepScreenAwake.key, value);
    await ScreenTimeoutService.setKeepScreenOn(value);
  },
  buildTile: (repo, value, shape) {
    return _buildBooleanTile(
      shape: shape,
      title: "Keep Screen Awake",
      description:
          "Prevent screen from locking\n"
          "Use this sparingly for OLED/AMOLED screens due to risk of pixel burn-in if left on for extended periods",
      currentValue: value as bool,
      onUpdate: () async => await repo.set(swipeUpHistory, !value),
    );
  },
);

final Setting<bool> disableHaptics = Setting(
  key: "disable_haptic",
  category: Category.functionality,
  read: (prefs) async => await prefs.getBool(disableHaptics.key) ?? false,
  write: (prefs, value) async {
    await _writeToStorageHelper(prefs, disableHaptics.key, value);
  },
  buildTile: (repo, value, shape) {
    return _buildBooleanTile(
      title: "Disable Haptic Feedback",
      description: "Remove vibrations when numpad buttons are pressed",
      shape: shape,
      currentValue: value as bool,
      onUpdate: () async => await repo.set(disableHaptics, !value),
    );
  },
);

// Extras Settings

final showLicenses = Setting<void>(
  key: "show_licenses",
  category: Category.extra,
  read: (prefs) async => {},
  write: (prefs, value) async {},
  buildTile: (repo, value, shape) {
    return Builder(
      builder: (context) {
        return Material(
          child: ListTile(
            shape: shape,
            title: const Text("Open Source Licenses"),
            trailing: const SizedBox(
              width: 48,
              child: NxIcon(path: NxIcon.right),
            ),
            onTap: () async {
              await Navigator.of(
                context,
              ).push(SlidePageRoute(page: const LicensesScreen()));
            },
          ),
        );
      },
    );
  },
);

final showPrivacyPolicy = Setting<void>(
  key: "privacy_policy",
  category: Category.extra,
  read: (prefs) async => {},
  write: (prefs, value) async {},
  buildTile: (repo, value, shape) {
    return Builder(
      builder: (context) {
        return Material(
          child: ListTile(
            shape: shape,
            title: const Text("Privacy Policy"),
            trailing: const SizedBox(
              width: 48,
              child: NxIcon(path: NxIcon.right),
            ),
            onTap: () async {
              await Navigator.of(
                context,
              ).push(SlidePageRoute(page: const PrivacyPolicyScreen()));
            },
          ),
        );
      },
    );
  },
);

Widget _buildBooleanTile({
  required String title,
  required bool currentValue,
  required VoidCallback onUpdate,
  String? description,
  ShapeBorder? shape,
}) {
  return Material(
    child: ListTile(
      shape: shape,
      onTap: () => onUpdate(),
      title: Text(title),
      subtitle: description != null ? Text(description) : null,
      trailing: Switch(value: currentValue, onChanged: (value) => onUpdate()),
    ),
  );
}

Widget _buildExpandableTile<T>({
  required String title,
  required T currentValue,
  required Function(T value) onUpdate,
  required List<T> selectableValues,
  String? description,
  ShapeBorder? shape,
}) {
  var icon = NxIcon.down;

  return StatefulBuilder(
    builder: (context, setState) {
      return Material(
        child: ExpansionTile(
          shape: shape,
          collapsedShape: shape,
          initiallyExpanded: false,
          onExpansionChanged: (value) => setState(() {
            icon = value ? NxIcon.up : NxIcon.down;
          }),
          splashColor: Colors.transparent,
          title: Text(title),
          subtitle: Text("Current: $currentValue"),
          trailing: SizedBox(width: 48, child: NxIcon(path: icon)),
          children: selectableValues.map((value) {
            return ListTile(
              title: Text(
                "$value",
                style: TextStyle(fontFamily: value is String ? value : null),
              ),
              trailing: Switch(
                value: currentValue == value,
                onChanged: (_) => onUpdate(value),
              ),
              onTap: () => onUpdate(value),
            );
          }).toList(),
        ),
      );
    },
  );
}

Widget _buildMultiSettingTile<T>({
  required String title,
  required T currentValue,
  required Function(T value) onUpdate,
  required List<MultiSettingData<T>> selectableValues,
  String? description,
  ShapeBorder? shape,
}) {
  return Material(
    child: ListTile(
      shape: shape,
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: MultiSetting<T>(
          selected: currentValue,
          selectables: selectableValues,
          onSelectionChanged: (selection) => onUpdate(selection),
        ),
      ),
    ),
  );
}
