import "package:flutter/material.dart";
import "package:nxcalculator/models/history_item.dart";
import "package:nxcalculator/models/setting.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/screens/home/widgets/equation_input_field.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxcalculator/screens/home/widgets/dynamic_appbar.dart";
import "package:nxcalculator/widgets/history_listview.dart";
import "package:nxcalculator/screens/home/widgets/portrait_keypad.dart";
import "package:provider/provider.dart";

class PortraitLayout extends StatefulWidget {
  const PortraitLayout({super.key});

  @override
  State<PortraitLayout> createState() => _PortraitLayoutState();
}

class _PortraitLayoutState extends State<PortraitLayout> {
  final focusNode = FocusNode();
  var _isExtended = false;

  SettingsRepository get _settings => context.read<SettingsRepository>();
  CalculatorRepository get _calculator => context.read<CalculatorRepository>();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    _isExtended = _settings.get(startExtendedSetting);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsRepository>(
      builder: (context, settings, child) {
        return Column(
          children: [
            DynamicAppbar(
              padding: const EdgeInsets.only(left: 24),
              actions: [
                if (settings.get(preferBottomToolbarSetting) == false &&
                    settings.get(swipeUpHistorySetting) == false)
                  IconButton(
                    tooltip: "History",
                    icon: _isDark
                        ? Image.asset("assets/icons/dark/history.png")
                        : Image.asset("assets/icons/light/history.png"),
                    padding: const EdgeInsets.all(14),
                    onPressed: _showHistory,
                  ),
                if (settings.get(preferBottomToolbarSetting) == false)
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
                  const Flexible(child: SizedBox(height: 48)),
                  Consumer<CalculatorRepository>(
                    builder: (context, repo, child) {
                      return Padding(
                        padding: _getNumpadDensity(),
                        child: EquationInputField(
                          clip: false,
                          maxFontSize: 72,
                          minFontSize: 38,
                          focusNode: focusNode,
                          style: const TextStyle(height: 1),
                          equation: repo.equation,
                          onSelectionChanged: (cursorPosition) {
                            repo.setCursorFromCharOffset(cursorPosition);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Consumer<CalculatorRepository>(
                    builder: (context, repo, child) {
                      final text = repo.result == "" && repo.error != ""
                          ? repo.error
                          : getFormattedResult(
                              repo.result,
                              maxIntegerDigits: 13,
                              maxFractionDigits: 13,
                              settings: settings,
                            );

                      return Padding(
                        padding: _getNumpadDensity(),
                        child: SelectableText(
                          text,
                          maxLines: 1,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            height: 1,
                            fontSize: _getNumpadDensity().horizontal > 24
                                ? 38
                                : 40,
                            color: Colors.grey[600],
                            fontFamily: _settings.get(
                              equationResultFontSetting,
                            ),
                            letterSpacing:
                                _settings.get(equationResultFontSetting) ==
                                    "LetteraMono"
                                ? -7
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  settings.get(preferBottomToolbarSetting)
                      ? SizedBox(
                          height: 56,
                          child: Padding(
                            padding: _getNumpadDensity(),
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: "Scientific",
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _isExtended ? nothingRed : null,
                                      shape: BoxShape.circle,
                                    ),
                                    child: _isDark
                                        ? Image.asset(
                                            "assets/icons/dark/function.png",
                                          )
                                        : _isExtended
                                        ? Image.asset(
                                            "assets/icons/dark/function.png",
                                          )
                                        : Image.asset(
                                            "assets/icons/light/function.png",
                                          ),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  onPressed: () {
                                    setState(() => _isExtended = !_isExtended);
                                  },
                                ),
                                const SizedBox(width: 16),
                                if (settings.get(swipeUpHistorySetting) ==
                                    false)
                                  IconButton(
                                    tooltip: "History",
                                    icon: _isDark
                                        ? Image.asset(
                                            "assets/icons/dark/history.png",
                                          )
                                        : Image.asset(
                                            "assets/icons/light/history.png",
                                          ),
                                    padding: const EdgeInsets.all(14),
                                    onPressed: _showHistory,
                                  ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(height: 56),
                  const SizedBox(height: 8),
                  Padding(
                    padding: _getNumpadDensity(),
                    child: Consumer<CalculatorRepository>(
                      builder: (context, repo, child) {
                        return GestureDetector(
                          onVerticalDragEnd: (details) async {
                            if (_settings.get(swipeUpHistorySetting)) {
                              if (details.primaryVelocity != null &&
                                  details.primaryVelocity! < -800) {
                                await _showHistory();
                              }
                            }
                          },
                          child: PortraitKeypad(
                            mode: repo.mode,
                            isExtended: _isExtended,
                            isInverted: repo.inverted,
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
                                    _calculator.insertToken(
                                      result.substring(1),
                                    );
                                  } else {
                                    _calculator.insertToken(result);
                                  }
                                } else {
                                  _calculator.insertToken(result);
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showHistory() async {
    final item = await showModalBottomSheet<HistoryItem>(
      context: context,
      showDragHandle: true,
      scrollControlDisabledMaxHeightRatio: 0.6,
      builder: (context) {
        return FutureBuilder(
          future: _calculator.loadHistory(),
          builder: (context, asyncSnapshot) {
            return HistoryListview(
              history: _calculator.history,
              onTapItem: (item) => Navigator.of(context).pop(item),
              onDelete: (index) async =>
                  await _calculator.removeFromHistory(index),
            );
          },
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (item != null) {
      _calculator.clear();
      if (item.result.contains("E")) {
        if (item.result.startsWith("-")) {
          _calculator.addOperation("-");
          _calculator.insertToken(item.result.substring(1));
        } else {
          _calculator.insertToken(item.result);
        }
      } else {
        _calculator.insertToken(item.result);
      }
    }
  }

  EdgeInsets _getNumpadDensity() {
    return EdgeInsets.symmetric(
      horizontal: switch (_settings.get(numpadDensitySetting)) {
        NumpadDensity.comfy => 12,
        NumpadDensity.dense => 32,
        _ => 24,
      },
    );
  }
}
