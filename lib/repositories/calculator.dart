import "package:flutter/material.dart";
import "package:math_expressions/math_expressions.dart";
import "package:nxcalculator/models/history_item.dart";
import "package:shared_preferences/shared_preferences.dart";

/* 
Rules of this calculator (implied & hard-coded)
1. The percantage operator is applied only to the last token
2. If the last token is a closing bracket, the percentage operator applies to
    computed value of the grouping
3. Implicit multiplication is applied when a digit/function is placed next to 
    another function/symbol
4. Operators cannot be chained except if the leading operator is the percentage 
    operator
5. Closing brackets are automatically placed at the end of the equation if none 
    are supplied
6. One can only apply a square to a number/constant once
*/

const calculatorHistoryKey = "calculator_history";

// TODO: add comments
class CalculatorRepository with ChangeNotifier {
  final _maxHistoryItems = 50;

  final equation = <String>[];
  final history = <HistoryItem>[];

  var result = "";
  var _mode = "DEG";

  var _openBrackets = 0;
  var inverted = false;

  var cursor = 0;

  /*
    Helper Functions
  */

  bool _isNumber(String s) => RegExp(r"(\d+)(\.?\d+)?").hasMatch(s);

  bool _isConstant(String s) => s == "π" || s == "e";

  bool _isImpliedValue(String s) =>
      _isNumber(s) ||
      _isConstant(s) ||
      s == "%" ||
      s == "!" ||
      s == ")" ||
      s == "^2";

  bool _isLeadingValue(String s) =>
      _isNumber(s) || _isConstant(s) || s == "(" || s.endsWith("(");

  bool _isPureNumberExpression() {
    var hasDecimal = false;

    for (final token in equation) {
      if (_isNumber(token)) {
        continue;
      }

      if (token == "." && !hasDecimal) {
        hasDecimal = true;
        continue;
      }

      return false;
    }

    return true;
  }

  void _insertToken(String token) {
    equation.insert(cursor, token);
    cursor++;

    if (token.endsWith("(")) {
      _openBrackets++;
    }
    if (token == ")") {
      _openBrackets--;
    }
  }

  void setCursorFromCharOffset(int offset) {
    var count = 0;

    for (var i = 0; i < equation.length; i++) {
      count += equation[i].length;
      if (offset <= count) {
        cursor = i + 1;
        return;
      }
    }
    cursor = equation.length;
    notifyListeners();
  }

  /*
    Calculator Functions
  */

  void addDigit(String digit) {
    final chars = digit.split("");
    for (final char in chars) {
      _insertToken(char);
    }
    notifyListeners();
  }

  void addDecimal() {
    if (cursor == 0) {
      return;
    }

    if (!_isNumber(equation[cursor - 1])) {
      return;
    }

    for (var i = cursor - 1; i >= 0; i--) {
      final token = equation[i];

      if (token == ".") {
        return;
      }

      if (!_isNumber(token)) {
        break;
      }
    }

    _insertToken(".");
    notifyListeners();
  }

  void addOperation(String operation) {
    if (operation == "-") {
      /* 
      If required to support binary operators, add the following check:
      RegExp(r"^[+\-×÷^]$").hasMatch(equation[cursor - 1])
      */
      if (cursor == 0 || equation[cursor - 1].endsWith("(")) {
        _insertToken(operation);
        notifyListeners();
        return;
      }
    }

    if (cursor == 0) {
      return;
    }

    final prev = equation[cursor - 1];

    if (!_isImpliedValue(prev)) {
      return;
    }

    _insertToken(operation);
    notifyListeners();
  }

  void addFunction(String function) {
    switch (function) {
      case "{sin}":
        _insertToken(inverted ? "arcsin(" : "sin(");
      case "{cos}":
        _insertToken(inverted ? "arccos(" : "cos(");
      case "{tan}":
        _insertToken(inverted ? "arctan(" : "tan(");
      case "{ln}":
        _insertToken(inverted ? "exp(" : "ln(");
      case "{log}":
        _insertToken(inverted ? "10^(" : "log(");
      case "{exponent}":
        _insertToken("e");
      case "{pi}":
        _insertToken("π");
      case "{power}":
        if (cursor == 0) {
          return;
        }

        final prev = equation[cursor - 1];

        if (_isNumber(prev) || _isConstant(prev) || prev == ")") {
          _insertToken("^");
        }
      case "{factorial}":
        if (cursor == 0) {
          return;
        }

        final prev = equation[cursor - 1];

        if (_isNumber(prev) || _isConstant(prev) || prev == ")") {
          _insertToken("!");
        }
      case "{root}":
        if (inverted) {
          if (cursor == 0) {
            return;
          }

          final prev = equation[cursor - 1];

          if (_isNumber(prev) || _isConstant(prev) || prev == ")") {
            _insertToken("^2");
          }
        } else {
          _insertToken("sqrt(");
        }
      default:
    }
    notifyListeners();
  }

  void addBracket() {
    if (cursor == 0) {
      _insertToken("(");
      notifyListeners();
      return;
    }

    final canOpen =
        _openBrackets == 0 ||
        equation.isEmpty ||
        equation[cursor - 1].contains(RegExp(r"[+\-×÷(]"));

    _insertToken(canOpen ? "(" : ")");
    notifyListeners();
  }

  void addPercent() {
    if (cursor == 0) {
      return;
    }

    final prev = equation[cursor - 1];

    if (_isNumber(prev) || _isConstant(prev) || prev == ")") {
      _insertToken("%");

      notifyListeners();
    }
  }

  void delete() {
    if (cursor == 0) {
      if (equation.length == 1) {
        cursor++;
      } else {
        return;
      }
    }

    final token = equation.removeAt(cursor - 1);
    cursor--;

    if (token.endsWith("(")) {
      _openBrackets--;
    }
    if (token == ")") {
      _openBrackets++;
    }

    if (equation.isEmpty) {
      clear();
    }

    notifyListeners();
  }

  void clear() {
    _openBrackets = 0;
    cursor = 0;
    result = "";
    equation.clear();
    notifyListeners();
  }

  void invertFunctions() {
    inverted = !inverted;
  }

  void toggleMode(String mode) {
    _mode = mode;

    notifyListeners();
  }

  void evaluate() {
    result = "";

    final finalEquation = _convertTrigForMode(_getFormattedEquation());

    try {
      final parser = GrammarParser();
      final expression = parser.parse(finalEquation);

      final model = ContextModel();
      final value = RealEvaluator(model).evaluate(expression);

      if (value.isNaN) {
        result = "Domain Error";
      } else if (value.isInfinite) {
        result = "Infinity";
      } else if (value % 1 == 0) {
        result = value.toStringAsFixed(0);
      } else {
        result = value.toStringAsFixed(12).replaceFirst(RegExp(r"\.?0+$"), "");
      }
    } catch (e) {
      if (equation.isNotEmpty && e is FormatException) {
        result = "Format Error";
      } else {
        result = "Error";
      }
    }
    notifyListeners();
  }

  /*
    Local Storage Functions
  */

  Future<bool> saveHistory({bool checkLast = true}) async {
    final item = HistoryItem(result: result, equation: [...equation]);

    if (checkLast) {
      if (history.isNotEmpty && history.first.equals(item)) {
        return false;
      }

      if (!_isNumber(result)) {
        return false;
      }

      if (_isPureNumberExpression()) {
        return false;
      }

      if (equation.length == 1 && _isConstant(equation[0])) {
        return false;
      }

      history.insert(0, item);
    }

    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    final prefs = SharedPreferencesAsync();
    final data = history.map((item) => item.serialize()).toList();

    await prefs.setStringList(calculatorHistoryKey, data);

    await loadHistory();

    return true;
  }

  Future<void> loadHistory() async {
    final prefs = SharedPreferencesAsync();
    final data = await prefs.getStringList(calculatorHistoryKey);

    if (data == null) {
      return;
    }

    history.clear();
    history.addAll(data.map((item) => HistoryItem.fromData(item)));
    notifyListeners();
  }

  Future<void> clearHistory() async {
    final prefs = SharedPreferencesAsync();
    await prefs.remove(calculatorHistoryKey);

    history.clear();
    notifyListeners();
  }

  String _getFormattedEquation() {
    final buffer = <String>[];

    for (var i = 0; i < equation.length; i++) {
      final current = equation[i];

      buffer.add(current);

      if (i == equation.length - 1) {
        continue;
      }

      final next = equation[i + 1];

      if (_isNumber(current) && _isNumber(next)) {
        continue;
      }

      final needsMultiplication =
          _isImpliedValue(current) && _isLeadingValue(next);

      if (needsMultiplication) {
        buffer.add("*");
      }
    }

    // Close all unclosed brackets
    if (_openBrackets != 0) {
      buffer.addAll(List.filled(_openBrackets, ")"));
    }

    return buffer
        .join()
        .replaceAll("×", "*")
        .replaceAll("÷", "/")
        .replaceAll("π", "pi")
        .replaceAll("%", "/100")
        .replaceAll("exp(", "e(")
        .replaceAll("log(", "log(10,");
  }

  String _convertTrigForMode(String equation) {
    if (_mode == "RAD") {
      return equation;
    }

    String convertRecursively(String expr) {
      final buffer = StringBuffer();

      bool isInverseTrig(String fn) =>
          fn == "arcsin" || fn == "arccos" || fn == "arctan";

      String? matchTrig(String expr, int index) {
        const functions = ["arcsin", "arccos", "arctan", "sin", "cos", "tan"];

        for (final fn in functions) {
          if (expr.startsWith(fn, index)) {
            return fn;
          }
        }
        return null;
      }

      var i = 0;
      while (i < expr.length) {
        final trigMatch = matchTrig(expr, i);

        if (trigMatch != null) {
          final fn = trigMatch;
          i += fn.length;

          final start = i + 1;
          var depth = 1;
          var j = start;

          while (j < expr.length && depth > 0) {
            switch (expr[j]) {
              case "(":
                depth++;
              case ")":
                depth--;
            }
            j++;
          }

          final inner = expr.substring(start, j - 1);
          final convertedInner = convertRecursively(inner);

          if (isInverseTrig(fn)) {
            buffer.write("($fn($convertedInner) * 180 / pi)");
          } else {
            buffer.write("$fn(($convertedInner) * pi / 180)");
          }

          i = j;
        } else {
          buffer.write(expr[i]);
          i++;
        }
      }

      return buffer.toString();
    }

    return convertRecursively(equation);
  }
}
