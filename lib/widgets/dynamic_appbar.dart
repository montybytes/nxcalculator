import "package:flutter/material.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/utils/ui.dart";
import "package:nxcalculator/widgets/confirm_action_dialog.dart";
import "package:provider/provider.dart";

class DynamicAppbar extends StatefulWidget {
  const DynamicAppbar({super.key, this.padding, this.actions});

  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;

  @override
  State<DynamicAppbar> createState() => _DynamicAppbarState();
}

class _DynamicAppbarState extends State<DynamicAppbar> {
  final _menuKey = GlobalKey();

  bool get _isDark =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  CalculatorRepository get _repo => context.read<CalculatorRepository>();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Padding(
          padding: widget.padding ?? EdgeInsetsGeometry.zero,
          child: AppBar(
            titleSpacing: 0,
            title: const Text(
              "Calculator",
              style: TextStyle(fontFamily: "Ntype-82", fontSize: 36),
              strutStyle: StrutStyle(forceStrutHeight: true, fontSize: 36),
            ),
            actions: [
              ...?widget.actions,
              IconButton(
                tooltip: "Options",
                key: _menuKey,
                icon: _isDark
                    ? Image.asset("assets/icons/dark/more.png")
                    : Image.asset("assets/icons/light/more.png"),
                padding: const EdgeInsets.all(14),
                onPressed: _showPopupMenu,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPopupMenu() async {
    final button = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset bottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
    );

    final position = RelativeRect.fromRect(
      Rect.fromPoints(bottomRight, bottomRight),
      Offset.zero & overlay.size,
    );

    final value = await showMenu<String>(
      context: context,
      color: _isDark ? darkThemeCard : lightThemeCard,
      shape: buildListTileBorder(0, 1),
      position: position,
      items: const [
        PopupMenuItem(
          value: "clear_history",
          child: Text("Clear History", style: TextStyle(fontSize: 18)),
        ),
      ],
    );

    switch (value) {
      case "clear_history":
        if (mounted) {
          final shouldClear = await showDialog<bool>(
            context: context,
            builder: (context) => const ConfirmActionDialog(
              titleText: "Clear History",
              infoText: "Are you sure you want to clear all history?",
            ),
          );

          if (shouldClear ?? false) {
            await _repo.clearHistory();
          }
        }
      default:
    }
  }
}
