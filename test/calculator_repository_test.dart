import "package:flutter_test/flutter_test.dart";
import "package:nxcalculator/models/history_item.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart";
import "package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Input Tests", () {
    test("add digits", () {
      final repo = CalculatorRepository();

      repo.addDigit("1");
      expect(repo.equation, ["1"]);

      repo.addDigit("2");
      expect(repo.equation, ["1", "2"]);

      repo.addDigit("34");
      expect(repo.equation, ["1", "2", "3", "4"]);
    });

    test("add constants", () {
      final repo = CalculatorRepository();

      repo.addConstant("e");
      expect(repo.equation, ["e"]);

      repo.addConstant("π");
      expect(repo.equation, ["e", "π"]);
    });

    test("add decimal point", () {
      final repo = CalculatorRepository();

      repo.addDigit("1");
      expect(repo.equation, ["1"]);

      repo.addDecimal();
      expect(repo.equation, ["1", "."]);

      repo.addDigit("1");
      expect(repo.equation, ["1", ".", "1"]);
    });

    test("add operator", () {
      final repo = CalculatorRepository();

      repo.addOperation("-");
      expect(repo.equation, ["-"]);

      repo.addDigit("1");
      expect(repo.equation, ["-", "1"]);

      repo.addOperation("+");
      expect(repo.equation, ["-", "1", "+"]);

      repo.addDigit("1");
      expect(repo.equation, ["-", "1", "+", "1"]);

      repo.addPercent();
      expect(repo.equation, ["-", "1", "+", "1", "%"]);

      repo.addOperation("-");
      expect(repo.equation, ["-", "1", "+", "1", "%", "-"]);

      repo.addDigit("2");
      expect(repo.equation, ["-", "1", "+", "1", "%", "-", "2"]);
    });

    test("add function", () {
      final repo = CalculatorRepository();

      repo.addFunction("{sin}");
      expect(repo.equation, ["sin("]);

      repo.addFunction("{cos}");
      expect(repo.equation, ["sin(", "cos("]);

      repo.addFunction("{tan}");
      expect(repo.equation, ["sin(", "cos(", "tan("]);

      repo.clear();

      repo.addFunction("{power}");
      expect(repo.equation, []);

      repo.addDigit("2");
      repo.addFunction("{power}");
      expect(repo.equation, ["2", "^"]);

      repo.clear();

      repo.addFunction("{factorial}");
      expect(repo.equation, []);

      repo.addDigit("2");
      repo.addFunction("{factorial}");
      expect(repo.equation, ["2", "!"]);

      repo.clear();

      repo.addFunction("{root}");
      expect(repo.equation, ["sqrt("]);
      repo.clear();

      repo.invertFunctions();

      repo.addFunction("{ln}");
      expect(repo.equation, ["exp("]);
      repo.clear();

      repo.addFunction("{log}");
      expect(repo.equation, ["10^("]);
      repo.clear();

      repo.addFunction("{root}");
      expect(repo.equation, []);
      repo.addDigit("2");
      repo.addFunction("{root}");
      expect(repo.equation, ["2", "^2"]);
      repo.clear();

      repo.addFunction("{unknown}");
      expect(repo.equation, []);
    });

    test("add bracket symbol", () {
      final repo = CalculatorRepository();

      repo.addBracket();
      expect(repo.equation, ["("]);

      repo.addDigit("1");
      expect(repo.equation, ["(", "1"]);

      repo.addBracket();
      expect(repo.equation, ["(", "1", ")"]);
    });

    test("edit cursor location", () {
      final repo = CalculatorRepository();

      repo.addDigit("1");
      repo.addDigit("2");

      repo.setCursorFromCharOffset(1);
      expect(repo.cursor, 1);

      repo.setCursorFromCharOffset(3);
      expect(repo.cursor, repo.equation.length);
    });

    test("replace operator", () {
      final repo = CalculatorRepository();

      repo.addDigit("1");
      repo.addOperation("+");
      repo.addOperation("-");
      repo.addFunction("{power}");
      expect(repo.equation, ["1", "^"]);
    });

    test("clear all inputs", () {
      final repo = CalculatorRepository();

      repo.addDigit("1");
      repo.addDigit("2");
      expect(repo.equation, ["1", "2"]);

      repo.clear();
      expect(repo.equation, []);
    });

    test("delete input left of cursor", () {
      final repo = CalculatorRepository();

      repo.addDigit("1");
      repo.addFunction("{sin}");
      repo.addDigit("2");
      repo.addBracket();
      expect(repo.equation, ["1", "sin(", "2", ")"]);

      repo.setCursorFromCharOffset(2);
      repo.delete();
      expect(repo.equation, ["1", "2", ")"]);

      repo.setCursorFromCharOffset(2);
      repo.delete();
      expect(repo.equation, ["1", ")"]);

      repo.delete();
      repo.delete();
      expect(repo.equation, []);

      repo.clear();

      repo.addDigit("1");
      repo.addDigit("2");
      repo.addDigit("3");
      repo.setCursorFromCharOffset(1);
      repo.delete();
      repo.delete();
      expect(repo.equation, ["2", "3"]);
    });
  });

  group("Evaluation Tests", () {
    test("evaluate proper equation", () {
      final repo = CalculatorRepository();

      repo.addDigit("3");
      repo.addOperation("+");
      repo.addDigit("3");
      repo.evaluate();
      expect(repo.result, "6");

      repo.clear();

      repo.addFunction("{sin}");
      repo.addDigit("3");
      repo.addDigit("0");
      repo.addOperation("+");
      repo.addFunction("{root}");
      repo.addConstant("π");
      repo.addBracket();
      repo.addBracket();
      repo.addPercent();
      repo.addDigit("2");
      repo.addFunction("{factorial}");
      repo.addOperation("+");
      repo.addFunction("{log}");
      repo.addDigit("1");
      repo.addDigit("0");
      repo.addBracket();
      expect(repo.equation, [
        "sin(",
        "3",
        "0",
        "+",
        "sqrt(",
        "π",
        ")",
        ")",
        "%",
        "2",
        "!",
        "+",
        "log(",
        "1",
        "0",
        ")",
      ]);

      repo.evaluate();
      expect(repo.result, "1.00698044081646");
    });

    test("evaluate incorrect equation", () {
      final repo = CalculatorRepository();

      repo.addFunction("{ln}");
      repo.evaluate(printError: true);
      expect(repo.error, "Format Error");

      repo.clear();

      repo.addDigit("2");
      repo.addFunction("{factorial}");
      repo.addOperation("-");
      repo.evaluate(printError: true);
      expect(repo.error, "Format Error");

      repo.clear();

      repo.invertFunctions();
      repo.addFunction("{sin}");
      repo.addDigit("2");
      repo.evaluate(printError: true);
      expect(repo.error, "Domain Error");

      repo.clear();
    });

    test("evaluate divide by zero", () {
      final repo = CalculatorRepository();

      repo.addDigit("2");
      repo.addOperation("÷");
      repo.addDigit("0");
      repo.evaluate(printError: true);
      expect(repo.result, "");
      expect(repo.error, "Division By Zero");

      repo.clear();

      repo.addDigit("2");
      repo.addOperation("÷");
      repo.addBracket();
      repo.addDigit("2");
      repo.addOperation("-");
      repo.addDigit("2");
      repo.evaluate(printError: true);
      expect(repo.error, "Division By Zero");
    });

    test("evaluate correct mode evaluation", () {
      final repo = CalculatorRepository();

      repo.addFunction("{sin}");
      repo.addDigit("30");
      repo.evaluate();
      expect(repo.result, "0.5");

      repo.clear();

      repo.toggleMode();
      repo.addFunction("{sin}");
      repo.addConstant("π");
      repo.addOperation("÷");
      repo.addDigit("6");
      repo.evaluate();
      expect(repo.result, "0.5");
    });
  });

  group("Storage Persistence Tests", () {
    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();

      final prefs = SharedPreferencesAsync();
      await prefs.clear();
    });

    test("store evaluated expression", () async {
      final repo = CalculatorRepository();

      repo.addDigit("3");
      repo.addOperation("+");
      repo.addDigit("3");
      repo.evaluate();
      final item = HistoryItem(
        result: repo.result,
        equation: [...repo.equation],
      );
      expect(await repo.saveHistory(item), true);
      expect(repo.history.length, 1);

      final prefs = SharedPreferencesAsync();
      final stored = await prefs.getStringList(calculatorHistoryKey);

      expect(stored, isNotNull);
      expect(stored!.length, 1);
    });

    test("store expression and trim history overflow", () async {
      final repo = CalculatorRepository();

      for (var i = 0; i <= 55; i++) {
        repo.addDigit("1");
        repo.addOperation("+");
        repo.addDigit("$i");
        repo.evaluate();
        final item = HistoryItem(
          result: repo.result,
          equation: [...repo.equation],
        );
        await repo.saveHistory(item);
        repo.clear();
      }
      expect(repo.history.length, 50);

      final prefs = SharedPreferencesAsync();
      final stored = await prefs.getStringList(calculatorHistoryKey);

      expect(stored, isNotNull);

      final items =
          stored?.map((item) => HistoryItem.fromData(item)).toList() ?? [];

      expect(items.length, 50);

      final lastExpression = HistoryItem(
        result: "56",
        equation: ["1", "+", "5", "5"],
      );

      expect(items.first.equals(lastExpression), true);
    });

    test("load stored history", () async {
      final repo = CalculatorRepository();

      await repo.loadHistory();
      expect(repo.history, isEmpty);

      final prefs = SharedPreferencesAsync();
      await prefs.setStringList(calculatorHistoryKey, [
        HistoryItem(result: "2", equation: ["1", "+", "1"]).serialize(),
      ]);
      await repo.loadHistory();
      expect(repo.history, isNotEmpty);
      expect(repo.history.length, 1);
    });

    test("clear stored history", () async {
      final repo = CalculatorRepository();
      final prefs = SharedPreferencesAsync();

      await repo.clearHistory();
      expect(repo.history, isEmpty);
      expect(await prefs.getStringList(calculatorHistoryKey), isNull);
    });
  });
}
