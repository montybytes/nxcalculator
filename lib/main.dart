import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:nxcalculator/screens/home/home.dart";
import "package:nxcalculator/theme/dark.dart";
import "package:nxcalculator/theme/light.dart";

final rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = Intl.systemLocale;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: "Flutter Demo",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
