import "package:flutter/material.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/screens/home/widgets/equation_input_field.dart";
import "package:nxcalculator/screens/home/widgets/result_text_field.dart";
import "package:nxcalculator/widgets/dynamic_appbar.dart";
import "package:nxcalculator/widgets/history_listview.dart";
import "package:nxcalculator/widgets/landscape_keypad.dart";
import "package:provider/provider.dart";

class LandscapeLayout extends StatefulWidget {
  const LandscapeLayout({super.key});

  @override
  State<LandscapeLayout> createState() => _LandscapeLayoutState();
}

class _LandscapeLayoutState extends State<LandscapeLayout> {
  CalculatorRepository get _repo => context.read<CalculatorRepository>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const DynamicAppbar(),
                Expanded(
                  child: Consumer<CalculatorRepository>(
                    builder: (context, repo, child) {
                      return FutureBuilder(
                        future: _repo.loadHistory(),
                        builder: (context, asyncSnapshot) {
                          return HistoryListview(
                            history: _repo.history,
                            onTapItem: (item) {
                              _repo.clear();
                              if (item.result.contains("E")) {
                                _repo.insertToken(item.result);
                              } else {
                                _repo.addDigit(item.result);
                              }
                            },
                            onDelete: (index) async {
                              _repo.history.removeAt(index);
                              await _repo.saveHistory(checkLast: false);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Consumer<CalculatorRepository>(
                            builder: (context, repo, child) {
                              return EquationInputField(
                                shrink: true,
                                style: const TextStyle(
                                  letterSpacing: -6,
                                  fontFamily: "LetteraMono",
                                  fontSize: 48,
                                ),
                                equation: repo.equation,
                                onSelectionChanged: (cursorPosition) {
                                  repo.setCursorFromCharOffset(cursorPosition);
                                },
                              );
                            },
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Consumer<CalculatorRepository>(
                            builder: (context, repo, child) {
                              return ResultTextField(
                                result: repo.result,
                                error: repo.error,
                                style: TextStyle(
                                  height: 1,
                                  fontSize: repo.result.length >= 12 ? 36 : 40,
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
                  Consumer<CalculatorRepository>(
                    builder: (context, repo, child) {
                      return LandscapeKeypad(
                        mode: repo.mode,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
