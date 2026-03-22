import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/screens/home/home.dart";
import "package:nxcalculator/services/screen_timeout.dart";
import "package:nxdesign/themes.dart";
import "package:provider/provider.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = Intl.systemLocale;

  final settingsRepo = SettingsRepository();
  await settingsRepo.load();

  runApp(ChangeNotifierProvider.value(value: settingsRepo, child: const App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      final settings = context.read<SettingsRepository>();
      final keepScreenOn = settings.get(keepScreenAwake);
      if (keepScreenOn) {
        await ScreenTimeoutService.setKeepScreenOn(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsRepository>(
      builder: (context, repo, child) {
        final mode = repo.get(themeMode);

        return MaterialApp(
          title: "NxCalculator",
          theme: NxTheme.lightTheme,
          darkTheme: NxTheme.darkTheme,
          themeMode: mode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
