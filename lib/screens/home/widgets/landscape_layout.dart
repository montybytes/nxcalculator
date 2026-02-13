import "package:flutter/material.dart";
import "package:nxcalculator/models/history_item.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/screens/home/widgets/equation_input_field.dart";
import "package:nxcalculator/utils/strings.dart";
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

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

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
                  child: FutureBuilder(
                    future: _repo.loadHistory(),
                    builder: (context, asyncSnapshot) {
                      return Consumer<CalculatorRepository>(
                        builder: (context, repo, child) {
                          return HistoryListview(
                            history: repo.history,
                            onTapItem: (item) {
                              repo.clear();
                              if (item.result.contains("E")) {
                                if (item.result.startsWith("-")) {
                                  repo.addOperation("-");
                                  repo.insertToken(item.result.substring(1));
                                } else {
                                  repo.insertToken(item.result);
                                }
                              } else {
                                repo.addDigit(item.result);
                              }
                            },
                            onDelete: (index) async =>
                                await repo.removeFromHistory(index),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Consumer<CalculatorRepository>(
                            builder: (context, repo, child) {
                              return EquationInputField(
                                equation: repo.equation,
                                maxFontSize: 48,
                                minFontSize: 48,
                                focusNode: focusNode,
                                style: const TextStyle(
                                  height: 1,
                                  fontFamily: "Inter",
                                ),
                                onSelectionChanged: (cursorPosition) {
                                  repo.setCursorFromCharOffset(cursorPosition);
                                },
                              );
                            },
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          flex: 2,
                          child: Consumer<CalculatorRepository>(
                            builder: (context, repo, child) {
                              final text = repo.result == "" && repo.error != ""
                                  ? repo.error
                                  : getFormattedResult(
                                      repo.result,
                                      maxIntegerDigits: 13,
                                      maxFractionDigits: 18,
                                    );

                              return SelectableText(
                                text,
                                maxLines: 1,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  height: 1,
                                  fontFamily: "Inter",
                                  fontSize: 38,
                                  color: Colors.grey[600],
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

                          final item = HistoryItem(
                            result: getFormattedResult(_repo.result),
                            equation: [..._repo.equation],
                          );

                          if (await _repo.saveHistory(item)) {
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
