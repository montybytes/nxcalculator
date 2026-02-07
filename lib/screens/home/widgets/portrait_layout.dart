import "package:flutter/material.dart";
import "package:nxcalculator/models/history_item.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/screens/home/widgets/equation_input_field.dart";
import "package:nxcalculator/screens/home/widgets/result_text_field.dart";
import "package:nxcalculator/theme/constants.dart";
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Consumer<CalculatorRepository>(
                        builder: (context, repo, child) {
                          return EquationInputField(
                            shrink: _isExtended,
                            equation: repo.equation,
                            style: TextStyle(
                              letterSpacing: -8,
                              fontFamily: "LetteraMono",
                              fontSize: _isExtended ? 68 : 80,
                            ),
                            onSelectionChanged: (cursorPosition) {
                              repo.setCursorFromCharOffset(cursorPosition);
                            },
                          );
                        },
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Consumer<CalculatorRepository>(
                        builder: (context, repo, child) {
                          return ResultTextField(
                            result: repo.result,
                            error: repo.error,
                            style: TextStyle(
                              height: 1,
                              fontSize: repo.result.length >= 12 ? 52 : 56,
                              letterSpacing: -6,
                              color: Colors.grey[700],
                              fontFamily: "LetteraMono",
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

                          if (await _repo.saveHistory()) {
                            _repo.clear();
                            if (_repo.history.first.result.contains("E")) {
                              _repo.insertToken(_repo.history.first.result);
                            } else {
                              _repo.addDigit(_repo.history.first.result);
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
              onDelete: (index) async {
                _repo.history.removeAt(index);
                await _repo.saveHistory(checkLast: false);
              },
            );
          },
        );
      },
    );

    if (item != null) {
      _repo.clear();
      if (item.result.contains("E")) {
        _repo.insertToken(item.result);
      } else {
        _repo.addDigit(item.result);
      }
    }
  }
}
