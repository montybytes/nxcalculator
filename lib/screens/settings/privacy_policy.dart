import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxdesign/fonts.dart";
import "package:nxdesign/widgets.dart";

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadPolicy(),
      builder: (context, snapshot) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                AppBar(
                  titleSpacing: 0,
                  title: const Text(
                    "Privacy Policy",
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SelectableText(snapshot.data ?? "ERROR"),
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

  Future<String> _loadPolicy() async {
    return await rootBundle.loadString("assets/privacy_policy.txt");
  }
}
