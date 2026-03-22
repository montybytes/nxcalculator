import "package:flutter/material.dart";
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
                    icon: const NxIcon(path: NxIcon.back),
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

                                  return setting.buildTile(repo, value, shape);
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
}
