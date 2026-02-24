import "package:flutter/material.dart";
import "package:nxcalculator/models/setting.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/screens/settings/widgets/multi_selectable_setting_tile.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxcalculator/utils/ui.dart";
import "package:nxcalculator/widgets/custom_checkbox.dart";
import "package:nxcalculator/widgets/custom_switch.dart";
import "package:provider/provider.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SettingsRepository>(
      builder: (context, repo, child) {
        final grouped = repo.getGrouped();

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppBar(
                  titleSpacing: 0,
                  title: const Text(
                    "Settings",
                    style: TextStyle(fontFamily: "NType", fontSize: 36),
                    strutStyle: StrutStyle(
                      forceStrutHeight: true,
                      fontSize: 36,
                    ),
                  ),
                  leading: IconButton(
                    tooltip: "Back",
                    icon: isDark
                        ? Image.asset("assets/icons/dark/back.png")
                        : Image.asset("assets/icons/light/back.png"),
                    padding: const EdgeInsets.all(14),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  child: Consumer<SettingsRepository>(
                    builder: (context, repo, child) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomScrollView(
                          slivers: [
                            for (final entry in grouped.entries) ...[
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    32,
                                    16,
                                    12,
                                  ),
                                  child: Text(entry.key.capitalize()),
                                ),
                              ),

                              // Settings List
                              SliverList.separated(
                                itemCount: entry.value.length,
                                itemBuilder: (context, index) {
                                  final setting = entry.value[index];
                                  final value = repo.get(setting);
                                  final shape = buildListTileBorder(
                                    index,
                                    entry.value.length,
                                  );

                                  if (value is ThemeMode) {
                                    return _buildThemeModeTile(
                                      repo,
                                      setting as Setting<ThemeMode>,
                                      value,
                                      shape: shape,
                                    );
                                  }

                                  if (value is bool) {
                                    return _buildBooleanTile(
                                      repo,
                                      setting as Setting<bool>,
                                      value,
                                      shape: shape,
                                    );
                                  }

                                  if (value is String) {
                                    return _buildStringTile(
                                      repo,
                                      setting as Setting<String>,
                                      value,
                                      shape: shape,
                                    );
                                  }

                                  return _buildTypedTile(
                                    repo,
                                    setting,
                                    value,
                                    shape: shape,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 2);
                                },
                              ),
                              if (entry.key == "formatting" &&
                                  repo.hasSameSeparators)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: ListTile(
                                      dense: true,
                                      shape: buildListTileBorder(0, 1),
                                      tileColor: nothingRed,
                                      title: const Text(
                                        "Grouping and decimal separators have the same value. Output will be confusing to read!",
                                        style: TextStyle(color: darkThemeText),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 128),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBooleanTile(
    SettingsRepository settings,
    Setting<bool> setting,
    bool value, {
    ShapeBorder? shape,
  }) {
    return Material(
      child: ListTile(
        shape: shape,
        onTap: () => settings.set(setting, !value),
        title: Text(setting.name, style: const TextStyle(fontSize: 18)),
        subtitle: setting.description != null
            ? Text(setting.description!)
            : null,
        trailing: CustomSwitch(
          value: value,
          onChanged: (value) => settings.set(setting, value),
        ),
      ),
    );
  }

  Widget _buildStringTile(
    SettingsRepository settings,
    Setting<String> setting,
    String value, {
    ShapeBorder? shape,
  }) {
    var iconName = "expand";

    return StatefulBuilder(
      builder: (context, setState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Material(
          child: ExpansionTile(
            shape: shape,
            collapsedShape: shape,
            initiallyExpanded: false,
            onExpansionChanged: (value) => setState(() {
              iconName = value ? "contract" : "expand";
            }),
            title: Text(setting.name, style: const TextStyle(fontSize: 18)),
            subtitle: Text("Current: $value"),
            trailing: SizedBox.square(
              dimension: 32,
              child: isDark
                  ? Image.asset("assets/icons/dark/$iconName.png")
                  : Image.asset("assets/icons/light/$iconName.png"),
            ),
            children: ["Inter", "LetteraMono", "NDot", "NType"].map((font) {
              return ListTile(
                title: Text(font, style: TextStyle(fontFamily: font)),
                trailing: CustomCheckbox(
                  value: value == font,
                  onChanged: (value) => settings.set(setting, font),
                ),
                onTap: () => settings.set(setting, font),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildThemeModeTile(
    SettingsRepository settings,
    Setting<ThemeMode> setting,
    ThemeMode themeMode, {
    ShapeBorder? shape,
  }) {
    return Material(
      child: ListTile(
        shape: shape,
        title: Text(setting.name, style: const TextStyle(fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: MultiSettingTile<ThemeMode>(
            selected: themeMode,
            selectables: const [
              MultiSetting(label: "System", data: ThemeMode.system),
              MultiSetting(label: "Light", data: ThemeMode.light),
              MultiSetting(label: "Dark", data: ThemeMode.dark),
            ],
            onSelectionChanged: (selection) {
              settings.set(setting, selection);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTypedTile(
    SettingsRepository settings,
    Setting<dynamic> setting,
    dynamic typedValue, {
    ShapeBorder? shape,
  }) {
    final List<MultiSetting> selectables = switch (setting.key) {
      "grouping_separator" => const [
        MultiSetting(data: GroupingSeparator.system, label: "System"),
        MultiSetting(data: GroupingSeparator.comma, label: "Comma"),
        MultiSetting(data: GroupingSeparator.dot, label: "Dot"),
        MultiSetting(data: GroupingSeparator.space, label: "Space"),
      ],
      "decimal_separator" => const [
        MultiSetting(data: DecimalSeparator.system, label: "System"),
        MultiSetting(data: DecimalSeparator.comma, label: "Comma"),
        MultiSetting(data: DecimalSeparator.dot, label: "Dot"),
      ],
      "button_shape" => const [
        MultiSetting(data: NumpadShape.circular, label: "Circle"),
        MultiSetting(data: NumpadShape.rounded, label: "Rounded"),
        MultiSetting(data: NumpadShape.mixed, label: "Mixed"),
      ],
      "numpad_density" => const [
        MultiSetting(data: NumpadDensity.comfy, label: "Comfy"),
        MultiSetting(data: NumpadDensity.normal, label: "Normal"),
        MultiSetting(data: NumpadDensity.dense, label: "Dense"),
      ],
      "theme_mode" => const [
        MultiSetting(data: ThemeMode.system, label: "System"),
        MultiSetting(data: ThemeMode.light, label: "Light"),
        MultiSetting(data: ThemeMode.dark, label: "Dark"),
      ],
      _ => [],
    };

    return Material(
      child: ListTile(
        shape: shape,
        title: Text(setting.name, style: const TextStyle(fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: MultiSettingTile(
            selected: typedValue,
            selectables: selectables,
            onSelectionChanged: (selection) {
              settings.set(setting, selection);
            },
          ),
        ),
      ),
    );
  }
}
