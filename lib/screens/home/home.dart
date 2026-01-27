import "package:flutter/material.dart";
import "package:nxcalculator/models/history_item.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/screens/home/widgets/equation_input_field.dart";
import "package:nxcalculator/screens/home/widgets/result_text_field.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/utils/ui.dart";
import "package:nxcalculator/widgets/basic_keypad.dart";
import "package:nxcalculator/widgets/extended_keypad.dart";
import "package:nxcalculator/widgets/history_bottom_sheet.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = CalculatorRepository();
  final _menuKey = GlobalKey();

  var _isExtended = false;

  bool get _isDark =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calculator",
          style: TextStyle(fontFamily: "Ntype-82", fontSize: 32),
          strutStyle: StrutStyle(forceStrutHeight: true, fontSize: 32),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showModalBottomSheet<HistoryItem>(
                context: context,
                showDragHandle: true,
                scrollControlDisabledMaxHeightRatio: 0.6,
                builder: (context) {
                  return FutureBuilder(
                    future: _repo.loadHistory(),
                    builder: (context, asyncSnapshot) {
                      return HistoryBottomSheet(
                        history: _repo.history,
                        onDelete: (index) async {
                          _repo.history.removeAt(index);
                          await _repo.saveHistory(checkLast: false);
                        },
                      );
                    },
                  );
                },
              );

              if (result != null) {
                _repo.clear();
                _repo.addDigit(result.result);
              }
            },
            icon: Image.asset("assets/icons/history.png"),
            padding: const EdgeInsets.all(14),
          ),
          IconButton(
            onPressed: () {
              setState(() => _isExtended = !_isExtended);
            },
            icon: Image.asset("assets/icons/function.png"),
            padding: const EdgeInsets.all(14),
          ),
          IconButton(
            key: _menuKey,
            icon: Image.asset("assets/icons/more.png"),
            onPressed: _showPopupMenu,
            padding: const EdgeInsets.all(14),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ListenableBuilder(
                      listenable: _repo,
                      builder: (context, child) {
                        return EquationInputField(
                          shrink: _isExtended,
                          equation: _repo.equation,
                          onSelectionChanged: (cursorPosition) {
                            _repo.setCursorFromCharOffset(cursorPosition);
                          },
                        );
                      },
                    ),
                    ListenableBuilder(
                      listenable: _repo,
                      builder: (context, child) {
                        return ResultTextField(result: _repo.result);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isExtended)
                ExtendedKeypad(
                  onModePress: (value) {
                    _repo.toggleMode(value);
                    _repo.evaluate();
                  },
                  onInvertPress: (value) => _repo.invertFunctions(),
                  onFunctionPress: (value) {
                    _repo.addFunction(value);
                    switch (value) {
                      case "{root}" when _repo.inverted:
                      case "{exponential}":
                      case "{pi}":
                        _repo.evaluate();
                      default:
                    }
                  },
                ),
              BasicKeypad(
                isExtended: _isExtended,
                onDigitPress: (value) {
                  _repo.addDigit(value);
                  _repo.evaluate();
                },
                onDecimalPress: () => _repo.addDecimal(),
                onOperationPress: (value) {
                  switch (value) {
                    case "{bracket}":
                      _repo.addBracket();

                    case "{percent}":
                      _repo.addPercent();
                      _repo.evaluate();

                    default:
                      _repo.addOperation(value);
                  }
                },
                onEqualPress: () async {
                  _repo.evaluate();

                  if (await _repo.saveHistory()) {
                    _repo.clear();
                    _repo.addDigit(_repo.history.first.result);
                  }
                },
                onDeletePress: () => _repo.delete(),
                onClearPress: () => _repo.clear(),
              ),
            ],
          ),
        ),
      ),
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
          child: Text("Clear History", style: TextStyle(fontSize: 20)),
        ),
      ],
    );

    switch (value) {
      case "clear_history":
        await _repo.clearHistory();
      default:
    }
  }
}
