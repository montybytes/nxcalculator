import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxdesign/colors.dart";
import "package:nxdesign/fonts.dart";
import "package:nxdesign/widgets.dart";
import "package:provider/provider.dart";

class EquationInputField extends StatefulWidget {
  const EquationInputField({
    required this.equation,
    required this.onSelectionChanged,
    this.cursor = 0,
    this.maxFontSize = 48,
    this.minFontSize = 12,
    super.key,
  });

  final List<String> equation;
  final Function(int cursorPosition) onSelectionChanged;
  final int cursor;
  final double maxFontSize;
  final double minFontSize;

  @override
  State<EquationInputField> createState() => _EquationInputFieldState();
}

class _EquationInputFieldState extends State<EquationInputField> {
  final _editableKey = GlobalKey<EditableTextState>();

  late final FocusNode _focusNode;
  late final TextEditingController _textController;
  late final ScrollController _scrollController;

  CalculatorRepository get calculator => context.read<CalculatorRepository>();
  SettingsRepository get settings => context.read<SettingsRepository>();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..requestFocus();
    _textController = TextEditingController(text: _getFormattedEquation());
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant EquationInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentEquation = _getFormattedEquation();
    final cursorOffset = widget.equation
        .take(widget.cursor)
        .fold(0, (sum, token) => sum + token.length);

    final selection = TextSelection.collapsed(
      offset: cursorOffset.clamp(0, currentEquation.length),
    );

    _textController.value = TextEditingValue(
      text: currentEquation,
      selection: selection,
    );

    _editableKey.currentState?.hideToolbar();

    if (!selection.isValid || selection.baseOffset == currentEquation.length) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsRepository>(
      builder: (context, settings, child) {
        final font = settings.get(equationResultFont);

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth - 24;
            final displayText = _getFormattedEquation();
            final chosenSize = maxWidth.isInfinite || maxWidth <= 0
                ? widget.minFontSize
                : _findFontSizeThatFits(displayText, maxWidth);
            final fontSize = chosenSize > widget.minFontSize
                ? chosenSize
                : widget.minFontSize;

            return SingleChildScrollView(
              reverse: true,
              clipBehavior: Clip.none,
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: EditableText(
                key: _editableKey,
                maxLines: 1,
                forceLine: false,
                readOnly: true,
                showCursor: true,
                autocorrect: false,
                enableSuggestions: false,
                showSelectionHandles: true,
                enableInteractiveSelection: true,
                controller: _textController,
                focusNode: _focusNode,
                textAlign: TextAlign.right,
                cursorColor: NxColors.nothingRed,
                selectionColor: NxColors.nothingRed,
                backgroundCursorColor: NxColors.nothingRed,
                keyboardType: TextInputType.none,
                selectionControls: CalculatorSelectionControls(
                  onMessage: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      // TODO: update theme with snackbar theme
                      const SnackBar(
                        elevation: 0,
                        shape: StadiumBorder(),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: NxColors.nothingRed,
                        duration: Duration(milliseconds: 1500),
                        margin: EdgeInsets.fromLTRB(80, 0, 80, 18),
                        content: Center(
                          child: Row(
                            spacing: 8,
                            children: [
                              NxIcon(path: NxIcon.block),
                              Text(
                                "Pasted value too large!",
                                style: TextStyle(color: NxColors.darkThemeText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                scrollPhysics: const NeverScrollableScrollPhysics(),
                style: DefaultTextStyle.of(context).style.copyWith(
                  height: 1,
                  fontFamily: font,
                  fontSize: fontSize,
                  letterSpacing: font == NxFonts.fontLettera ? -6 : null,
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    calculator.clear();
                    return;
                  }
                  final newTokens = calculator.parseTokens(value);

                  calculator.clear();

                  String normalizeToken(String token) {
                    token = token.trim().replaceAll(" ", "");

                    final groupSep = mapGroupingSeparator(
                      settings.get(groupingSeparator),
                    );
                    final decimalSep = mapDecimalSeparator(
                      settings.get(decimalSeparator),
                    );

                    final split = token.split("E");
                    var mantissa = split[0];
                    final exp = split.length > 1 ? split[1] : "";

                    mantissa = mantissa.replaceAll(groupSep, "");
                    mantissa = mantissa.replaceAll(decimalSep, ".");

                    return exp.isEmpty ? mantissa : "${mantissa}E$exp";
                  }

                  for (final token in newTokens) {
                    calculator.insertToken(normalizeToken(token));
                  }
                },
                onSelectionHandleTapped: () {
                  _editableKey.currentState?.showToolbar();
                },
                onSelectionChanged: (selection, cause) {
                  final start = selection.start;
                  final end = selection.end;

                  if (start != end) {
                    _editableKey.currentState?.showToolbar();
                  }

                  if (selection.isCollapsed) {
                    widget.onSelectionChanged(start);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  double _findFontSizeThatFits(String text, double maxWidth) {
    final font = settings.get(equationResultFont);

    double measureWidth(String text, double fontSize) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontFamily: font, fontSize: fontSize),
        ),
        textDirection: Directionality.of(context),
        maxLines: 1,
      );
      tp.layout();
      return tp.width;
    }

    if (measureWidth(text, widget.maxFontSize) <= maxWidth) {
      return widget.maxFontSize;
    }

    double low = widget.minFontSize;
    double high = widget.maxFontSize;
    double best = widget.minFontSize;

    for (var i = 0; i < 20; i++) {
      final mid = (low + high) / 2;
      final width = measureWidth(text, mid);
      if (width <= maxWidth) {
        best = mid;
        low = mid;
      } else {
        high = mid;
      }
    }

    if (best > widget.maxFontSize) {
      best = widget.maxFontSize;
    }
    if (best < widget.minFontSize) {
      best = widget.minFontSize;
    }
    return best;
  }

  String _getFormattedEquation() {
    return widget.equation.map((token) {
      return getFormattedToken(token, noGrouping: true, settings: settings);
    }).join();
  }
}

class CalculatorSelectionControls extends MaterialTextSelectionControls {
  CalculatorSelectionControls({this.onMessage});

  final Function(String message)? onMessage;

  @override
  bool canCut(TextSelectionDelegate delegate) {
    final selection = delegate.textEditingValue.selection;
    if (selection.isCollapsed) {
      return false;
    }
    return true;
  }

  @override
  bool canCopy(TextSelectionDelegate delegate) {
    final selection = delegate.textEditingValue.selection;
    if (selection.isCollapsed) {
      return false;
    }
    return true;
  }

  @override
  bool canPaste(TextSelectionDelegate delegate) {
    var canPaste = true;
    Clipboard.getData("text/plain").then((data) {
      canPaste = data != null && data.text != null && data.text!.isNotEmpty;
    });
    return canPaste;
  }

  @override
  bool canSelectAll(TextSelectionDelegate delegate) => true;

  @override
  Future<void> handleCut(TextSelectionDelegate delegate) async {
    final selection = delegate.textEditingValue.selection;
    final text = delegate.textEditingValue.text.substring(
      selection.start,
      selection.end,
    );

    await Clipboard.setData(ClipboardData(text: text.trim()));

    delegate.userUpdateTextEditingValue(
      TextEditingValue(
        text: delegate.textEditingValue.text.replaceRange(
          selection.start,
          selection.end,
          "",
        ),
      ),
      SelectionChangedCause.toolbar,
    );
    delegate.hideToolbar();
  }

  @override
  Future<void> handleCopy(TextSelectionDelegate delegate) async {
    final selection = delegate.textEditingValue.selection;
    final text = delegate.textEditingValue.text.substring(
      selection.start,
      selection.end,
    );

    await Clipboard.setData(ClipboardData(text: text.trim()));
    delegate.hideToolbar();
  }

  @override
  Future<void> handlePaste(TextSelectionDelegate delegate) async {
    final data = await Clipboard.getData("text/plain");

    if (data != null && data.text != null) {
      if (data.text!.length > 500) {
        onMessage?.call("Could not paste, data too large");
        return;
      }
      final value = delegate.textEditingValue;
      final selection = value.selection;

      final newText = value.text.replaceRange(
        selection.start,
        selection.end,
        data.text!.trim(),
      );

      delegate.userUpdateTextEditingValue(
        TextEditingValue(text: newText),
        SelectionChangedCause.toolbar,
      );
    }
    delegate.hideToolbar();
  }
}
