import "package:flutter/material.dart";
import "package:nxcalculator/screens/home/home.dart";
import "package:nxcalculator/theme/dark.dart";
import "package:nxcalculator/theme/light.dart";

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
