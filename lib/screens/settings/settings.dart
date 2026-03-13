import "package:flutter/material.dart" hide Switch, Checkbox;
import "package:nxcalculator/models/setting.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxcalculator/utils/ui.dart";
import "package:nxdesign/colors.dart";
import "package:nxdesign/fonts.dart";
import "package:nxdesign/widgets.dart";
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
                    style: TextStyle(
                      fontFamily: NxFonts.fontNType,
                      fontSize: 36,
                    ),
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
                                  final shape = RoundedRectangleBorder(
                                    borderRadius: getListTileBorder(
                                      index,
                                      entry.value.length,
                                    ),
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
                                const SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: ListTile(
                                      dense: true,
                                      tileColor: NxColors.nothingRed,
                                      title: Text(
                                        "Grouping and decimal separators have the same value. Output will be confusing to read!",
                                        style: TextStyle(
                                          color: NxColors.darkThemeText,
                                        ),
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
        trailing: Switch(
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
            children:
                [
                  NxFonts.fontInter,
                  NxFonts.fontLettera,
                  NxFonts.fontNDot,
                  NxFonts.fontNType,
                ].map((font) {
                  return ListTile(
                    title: Text(font, style: TextStyle(fontFamily: font)),
                    trailing: Checkbox(
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
          child: MultiSetting<ThemeMode>(
            selected: themeMode,
            selectables: const [
              MultiSettingData(label: "System", data: ThemeMode.system),
              MultiSettingData(label: "Light", data: ThemeMode.light),
              MultiSettingData(label: "Dark", data: ThemeMode.dark),
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
    final List<MultiSettingData> selectables = switch (setting.key) {
      "grouping_separator" => const [
        MultiSettingData(data: GroupingSeparator.system, label: "System"),
        MultiSettingData(data: GroupingSeparator.comma, label: "Comma"),
        MultiSettingData(data: GroupingSeparator.dot, label: "Dot"),
        MultiSettingData(data: GroupingSeparator.space, label: "Space"),
      ],
      "decimal_separator" => const [
        MultiSettingData(data: DecimalSeparator.system, label: "System"),
        MultiSettingData(data: DecimalSeparator.comma, label: "Comma"),
        MultiSettingData(data: DecimalSeparator.dot, label: "Dot"),
      ],
      "button_shape" => const [
        MultiSettingData(data: NumpadShape.circular, label: "Circle"),
        MultiSettingData(data: NumpadShape.rounded, label: "Rounded"),
        MultiSettingData(data: NumpadShape.mixed, label: "Mixed"),
      ],
      "numpad_density" => const [
        MultiSettingData(data: NumpadDensity.comfy, label: "Comfy"),
        MultiSettingData(data: NumpadDensity.normal, label: "Normal"),
        MultiSettingData(data: NumpadDensity.dense, label: "Dense"),
      ],
      "theme_mode" => const [
        MultiSettingData(data: ThemeMode.system, label: "System"),
        MultiSettingData(data: ThemeMode.light, label: "Light"),
        MultiSettingData(data: ThemeMode.dark, label: "Dark"),
      ],
      _ => [],
    };

    return Material(
      child: ListTile(
        shape: shape,
        title: Text(setting.name, style: const TextStyle(fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: MultiSetting(
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
