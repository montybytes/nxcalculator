import "package:flutter/foundation.dart";
import "package:flutter/material.dart" hide TextButton;
import "package:nxcalculator/utils/ui.dart";
import "package:nxdesign/fonts.dart";
import "package:nxdesign/widgets.dart";

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _groupLicenses(),
      builder: (context, snapshot) {
        final packages = snapshot.data ?? [];

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                AppBar(
                  titleSpacing: 0,
                  title: const Text(
                    "Licenses",
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Scrollbar(
                    thickness: 16,
                    interactive: true,
                    radius: const Radius.circular(16),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        final licenseCount = package.licenseTexts.length;
                        final shape = RoundedRectangleBorder(
                          borderRadius: getListTileBorder(
                            index,
                            packages.length,
                          ),
                        );

                        return Material(
                          child: ListTile(
                            shape: shape,
                            title: Text(package.packageName),
                            subtitle: Text(
                              "$licenseCount license${licenseCount != 1 ? "s" : ""}",
                            ),
                            onTap: () async {
                              await _buildLicenseDialog(
                                context,
                                package.licenseTexts,
                              );
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 2);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> _buildLicenseDialog(
    BuildContext context,
    List<List<LicenseParagraph>> licenses,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(16, 24, 16, 16),
            child: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Scrollbar(
                    thickness: 8,
                    interactive: true,
                    radius: const Radius.circular(8),
                    child: CustomScrollView(
                      shrinkWrap: true,
                      slivers: [
                        for (var i = 0; i < licenses.length; i++) ...[
                          SliverList.separated(
                            itemCount: licenses[i].length,
                            itemBuilder: (context, index) {
                              return SelectableText(licenses[i][index].text);
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                          ),
                          if (licenses.length > 1 && i < licenses.length - 1)
                            const SliverToBoxAdapter(child: Divider()),
                        ],
                      ],
                    ),
                  ),
                ),
                TextButton(
                  text: "CLOSE",
                  borderRadius: getListTileBorder(1, 2),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<LicenseEntry>> _groupLicenses() async {
    final map = <String, List<List<LicenseParagraph>>>{};

    await for (final entry in LicenseRegistry.licenses) {
      final packages = entry.packages.isEmpty ? ["Unknown"] : entry.packages;

      for (final pkg in packages) {
        map[pkg] = [...?map[pkg], entry.paragraphs.toList()];
      }
    }

    final data = <LicenseEntry>[];

    for (final key in map.keys) {
      data.add(
        LicenseEntry(
          packageName: key,
          licenseTexts: map[key]!.map((paragraphs) {
            return paragraphs.toList();
          }).toList(),
        ),
      );
    }

    data.sort((a, b) => a.packageName.compareTo(b.packageName));

    return data;
  }
}

class LicenseEntry {
  final String packageName;
  final List<List<LicenseParagraph>> licenseTexts;

  const LicenseEntry({required this.packageName, required this.licenseTexts});
}
