import "package:flutter/material.dart";
import "package:nxcalculator/screens/home/widgets/landscape_layout.dart";
import "package:nxcalculator/screens/home/widgets/portrait_layout.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return const LandscapeLayout();
            }
            return const PortraitLayout();
          },
        ),
      ),
    );
  }
}
