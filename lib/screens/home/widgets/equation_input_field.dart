import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxdesign/colors.dart";
import "package:nxdesign/fonts.dart";
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

  late final _baseStyle = DefaultTextStyle.of(context).style;

  CalculatorRepository get calculator => context.read<CalculatorRepository>();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..requestFocus();
    _textController = TextEditingController(text: widget.equation.join());
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant EquationInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentEquation = widget.equation.join();
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
        final font = settings.get(equationResultFontSetting);

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final chosenSize = maxWidth.isInfinite || maxWidth <= 0
                ? widget.minFontSize
                : _findFontSizeThatFits(
                    widget.equation.join(),
                    maxWidth,
                    _baseStyle,
                  );
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
                selectionControls: CalculatorSelectionControls(),
                scrollPhysics: const NeverScrollableScrollPhysics(),
                style: _baseStyle.copyWith(
                  height: 1,
                  fontFamily: font,
                  fontSize: fontSize,
                  letterSpacing: font == NxFonts.fontLettera ? -6 : null,
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    return;
                  }

                  final prevLength = widget.equation.join().length;
                  final currLength = value.length;
                  final isPasted = prevLength < currLength;

                  final newTokens = calculator.parseTokens(value);

                  calculator.clear();

                  for (final token in newTokens) {
                    calculator.insertToken(token);
                  }

                  final newEquation = calculator.equation.join();

                  var cursor = widget.cursor;

                  if (isPasted) {
                    cursor =
                        widget.equation.length -
                        (widget.equation.length - cursor);
                  }

                  _textController.value = TextEditingValue(
                    text: newEquation,
                    selection: TextSelection.collapsed(offset: cursor),
                  );
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

  double _findFontSizeThatFits(
    String text,
    double maxWidth,
    TextStyle baseStyle,
  ) {
    double measureWidth(String text, TextStyle textStyle) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      tp.layout();
      return tp.width;
    }

    if (measureWidth(text, baseStyle.copyWith(fontSize: widget.maxFontSize)) <=
        maxWidth) {
      return widget.maxFontSize;
    }

    double low = widget.minFontSize;
    double high = widget.maxFontSize;
    double best = widget.minFontSize;

    for (var i = 0; i < 20; i++) {
      final mid = (low + high) / 2;
      final width = measureWidth(text, baseStyle.copyWith(fontSize: mid));
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
}

class CalculatorSelectionControls extends MaterialTextSelectionControls {
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
