import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/screens/home/home.dart";
import "package:nxcalculator/theme/dark.dart";
import "package:nxcalculator/theme/light.dart";
import "package:provider/provider.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = Intl.systemLocale;

  final settingsRepo = SettingsRepository();
  await settingsRepo.load();

  runApp(ChangeNotifierProvider.value(value: settingsRepo, child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsRepository>(
      builder: (context, repo, child) {
        final themeMode = repo.get(themeModeSetting);

        return MaterialApp(
          title: "NxCalculator",
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
