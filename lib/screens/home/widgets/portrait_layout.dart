import "package:flutter/material.dart";
import "package:nxcalculator/main.dart";
import "package:nxcalculator/models/history_item.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/screens/home/widgets/equation_input_field.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxcalculator/widgets/dynamic_appbar.dart";
import "package:nxcalculator/widgets/history_listview.dart";
import "package:nxcalculator/widgets/portrait_keypad.dart";
import "package:provider/provider.dart";

class PortraitLayout extends StatefulWidget {
  const PortraitLayout({super.key});

  @override
  State<PortraitLayout> createState() => _PortraitLayoutState();
}

class _PortraitLayoutState extends State<PortraitLayout> {
  var _isExtended = false;

  CalculatorRepository get _repo => context.read<CalculatorRepository>();

  bool get _isDark =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    if (rootNavigatorKey.currentState?.canPop() ?? false) {
      rootNavigatorKey.currentState?.pop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DynamicAppbar(
          padding: const EdgeInsets.only(left: 24),
          actions: [
            IconButton(
              tooltip: "History",
              icon: _isDark
                  ? Image.asset("assets/icons/dark/history.png")
                  : Image.asset("assets/icons/light/history.png"),
              padding: const EdgeInsets.all(14),
              onPressed: _showHistory,
            ),
            IconButton(
              tooltip: "Scientific",
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _isExtended ? nothingRed : null,
                  shape: BoxShape.circle,
                ),
                child: _isDark
                    ? Image.asset("assets/icons/dark/function.png")
                    : _isExtended
                    ? Image.asset("assets/icons/dark/function.png")
                    : Image.asset("assets/icons/light/function.png"),
              ),
              padding: const EdgeInsets.all(10),
              onPressed: () {
                setState(() => _isExtended = !_isExtended);
              },
            ),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Consumer<CalculatorRepository>(
                        builder: (context, repo, child) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: EquationInputField(
                              clip: false,
                              maxFontSize: 72,
                              minFontSize: 38,
                              focusNode: focusNode,
                              style: const TextStyle(
                                height: 1,
                                fontFamily: "Inter",
                              ),
                              equation: repo.equation,
                              onSelectionChanged: (cursorPosition) {
                                repo.setCursorFromCharOffset(cursorPosition);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      flex: 3,
                      child: Consumer<CalculatorRepository>(
                        builder: (context, repo, child) {
                          final text = repo.result == "" && repo.error != ""
                              ? repo.error
                              : getFormattedResult(
                                  repo.result,
                                  maxIntegerDigits: 13,
                                  maxFractionDigits: 13,
                                );

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SelectableText(
                              text,
                              maxLines: 1,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                height: 1,

                                fontFamily: "Inter",
                                fontSize: 38,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Consumer<CalculatorRepository>(
                    builder: (context, repo, child) {
                      return PortraitKeypad(
                        mode: repo.mode,
                        isExtended: _isExtended,
                        isInverted: repo.inverted,
                        onDigitPress: (value) {
                          _repo.addDigit(value);
                          _repo.evaluate();
                        },
                        onConstantPress: (value) {
                          _repo.addConstant(value);
                          _repo.evaluate();
                        },
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
                        onFunctionPress: (String value) {
                          _repo.addFunction(value);
                          switch (value) {
                            case "{root}" when _repo.inverted:
                            case "{exponential}":
                            case "{pi}":
                              _repo.evaluate();
                            default:
                          }
                        },
                        onModePress: () {
                          _repo.toggleMode();
                          _repo.evaluate();
                        },
                        onInvertPress: () {
                          _repo.invertFunctions();
                        },
                        onDecimalPress: () {
                          _repo.addDecimal();
                        },
                        onDeletePress: () {
                          _repo.delete();
                        },
                        onClearPress: () {
                          _repo.clear();
                        },
                        onEqualPress: () async {
                          _repo.evaluate(printError: true);

                          final item = HistoryItem(
                            result: getFormattedResult(_repo.result),
                            equation: [..._repo.equation],
                          );

                          if (await _repo.saveHistory(item)) {
                            _repo.clear();

                            final result = _repo.history.first.result;
                            if (result.contains("E")) {
                              if (result.startsWith("-")) {
                                _repo.addOperation("-");
                                _repo.insertToken(result.substring(1));
                              } else {
                                _repo.insertToken(result);
                              }
                            } else {
                              _repo.addDigit(result);
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showHistory() async {
    final item = await showModalBottomSheet<HistoryItem>(
      context: context,
      showDragHandle: true,
      scrollControlDisabledMaxHeightRatio: 0.6,
      builder: (context) {
        return FutureBuilder(
          future: _repo.loadHistory(),
          builder: (context, asyncSnapshot) {
            return HistoryListview(
              history: _repo.history,
              onTapItem: (item) => Navigator.of(context).pop(item),
              onDelete: (index) async => await _repo.removeFromHistory(index),
            );
          },
        );
      },
    );

    if (item != null) {
      _repo.clear();
      if (item.result.contains("E")) {
        if (item.result.startsWith("-")) {
          _repo.addOperation("-");
          _repo.insertToken(item.result.substring(1));
        } else {
          _repo.insertToken(item.result);
        }
      } else {
        _repo.addDigit(item.result);
      }
    }
  }
}
