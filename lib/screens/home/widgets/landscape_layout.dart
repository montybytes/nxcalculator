import "package:flutter/material.dart";
import "package:nxcalculator/models/history_item.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/screens/home/widgets/equation_input_field.dart";
import "package:nxcalculator/screens/settings/settings.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxcalculator/screens/home/widgets/dynamic_appbar.dart";
import "package:nxcalculator/screens/home/widgets/history_listview.dart";
import "package:nxcalculator/screens/home/widgets/landscape_keypad.dart";
import "package:nxcalculator/widgets/slide_page_route.dart";
import "package:nxdesign/fonts.dart";
import "package:provider/provider.dart";

class LandscapeLayout extends StatefulWidget {
  const LandscapeLayout({super.key});

  @override
  State<LandscapeLayout> createState() => _LandscapeLayoutState();
}

class _LandscapeLayoutState extends State<LandscapeLayout> {
  var _collapsed = true;

  CalculatorRepository get _calculator => context.read<CalculatorRepository>();
  SettingsRepository get _settings => context.read<SettingsRepository>();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _collapsed
              ? SizedBox(
                  width: 56,
                  child: Column(
                    children: [
                      IconButton(
                        tooltip: "Settings",
                        icon: _isDark
                            ? Image.asset("assets/icons/dark/settings.png")
                            : Image.asset("assets/icons/light/settings.png"),
                        padding: const EdgeInsets.all(14),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(SlidePageRoute(page: const SettingsScreen()));
                        },
                      ),
                      IconButton(
                        tooltip: "Toggle Sidebar",
                        icon: _isDark
                            ? Image.asset("assets/icons/dark/panel_open.png")
                            : Image.asset("assets/icons/light/panel_open.png"),
                        padding: const EdgeInsets.all(14),
                        onPressed: () {
                          setState(() => _collapsed = !_collapsed);
                        },
                      ),
                    ],
                  ),
                )
              : Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      DynamicAppbar(
                        actions: [
                          IconButton(
                            tooltip: "Toggle Sidebar",
                            icon: _isDark
                                ? Image.asset(
                                    "assets/icons/dark/panel_close.png",
                                  )
                                : Image.asset(
                                    "assets/icons/light/panel_close.png",
                                  ),
                            padding: const EdgeInsets.all(14),
                            onPressed: () {
                              setState(() => _collapsed = !_collapsed);
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: FutureBuilder(
                          future: _calculator.loadHistory(),
                          builder: (context, asyncSnapshot) {
                            return Consumer<CalculatorRepository>(
                              builder: (context, repo, child) {
                                return HistoryListview(
                                  repo: _calculator,
                                  onTapItem: (item) {
                                    repo.clear();
                                    if (item.result.contains("E")) {
                                      if (item.result.startsWith("-")) {
                                        repo.addOperation("-");
                                        repo.insertToken(
                                          item.result.substring(1),
                                        );
                                      } else {
                                        repo.insertToken(item.result);
                                      }
                                    } else {
                                      repo.insertToken(item.result);
                                    }
                                  },
                                  onDelete: (index) async {
                                    await repo.removeFromHistory(index);
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
                spacing: 8,
                children: [
                  Consumer<CalculatorRepository>(
                    builder: (context, repo, child) {
                      return EquationInputField(
                        maxFontSize: 44,
                        minFontSize: 44,
                        cursor: repo.cursor,
                        equation: repo.equation,
                        onSelectionChanged: (cursorPosition) {
                          repo.setCursorFromCharOffset(cursorPosition);
                        },
                      );
                    },
                  ),
                  Consumer<CalculatorRepository>(
                    builder: (context, repo, child) {
                      final text = repo.result == "" && repo.error != ""
                          ? repo.error
                          : !repo.isPureNumberExpression
                          ? getFormattedResult(
                              repo.result,
                              maxIntegerDigits: 18,
                              maxFractionDigits: 18,
                            )
                          : "";

                      return SelectableText(
                        text,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          height: 1,
                          fontSize: 38,
                          color: Colors.grey[600],
                          fontFamily: _settings.get(equationResultFontSetting),
                          letterSpacing:
                              _settings.get(equationResultFontSetting) ==
                                  NxFonts.fontLettera
                              ? -6
                              : null,
                        ),
                      );
                    },
                  ),
                  Consumer<CalculatorRepository>(
                    builder: (context, repo, child) {
                      return LandscapeKeypad(
                        mode: repo.mode,
                        isInverted: repo.inverted,
                        fillHorizontalSpace: _collapsed,
                        onDigitPress: (value) {
                          _calculator.addDigit(value);
                          _calculator.evaluate();
                        },
                        onConstantPress: (value) {
                          _calculator.addConstant(value);
                          _calculator.evaluate();
                        },
                        onOperationPress: (value) {
                          switch (value) {
                            case "{bracket}":
                              _calculator.addBracket();

                            case "{percent}":
                              _calculator.addPercent();
                              _calculator.evaluate();

                            default:
                              _calculator.addOperation(value);
                          }
                        },
                        onFunctionPress: (String value) {
                          _calculator.addFunction(value);
                          switch (value) {
                            case "{root}" when _calculator.inverted:
                            case "{exponential}":
                            case "{pi}":
                              _calculator.evaluate();
                            default:
                          }
                        },
                        onModePress: () {
                          _calculator.toggleMode();
                          _calculator.evaluate();
                        },
                        onInvertPress: () {
                          _calculator.invertFunctions();
                        },
                        onDecimalPress: () {
                          _calculator.addDecimal();
                        },
                        onDeletePress: () {
                          _calculator.delete();
                        },
                        onClearPress: () {
                          _calculator.clear();
                        },
                        onEqualPress: () async {
                          _calculator.evaluate(printError: true);

                          final item = HistoryItem(
                            result: _calculator.result,
                            equation: [..._calculator.equation],
                          );

                          if (await _calculator.saveHistory(
                            item,
                            preventDuplicate: _settings.get(
                              preventDuplicateHistorySetting,
                            ),
                          )) {
                            _calculator.clear();
                            final result = _calculator.history.first.result;
                            if (result.contains("E")) {
                              if (result.startsWith("-")) {
                                _calculator.addOperation("-");
                                _calculator.insertToken(result.substring(1));
                              }
                            } else {
                              _calculator.insertToken(result);
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
