// ignore_for_file: library_prefixes

import "dart:math" as Math;

import "package:decimal/decimal.dart";
import "package:flutter_test/flutter_test.dart";
import "package:nxcalculator/backend/exception.dart";
import "package:nxcalculator/backend/expression.dart";
import "package:nxcalculator/backend/nodes.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Positive Tests", () {
    final engine = MathEngine();

    test("simple negation", () {
      final expression = engine.parse(["-", "10"]);
      expect(engine.evaluate(expression), Decimal.parse("-10.0"));
    });

    test("complex negation", () {
      final expression = engine.parse(["10", "+", "-", "(", "10", ")"]);
      expect(engine.evaluate(expression), Decimal.parse("0.0"));
    });

    test("simple arithmetic", () {
      final sum = engine.parse(["0.1", "+", "0.2"]);
      expect(engine.evaluate(sum), Decimal.parse("0.3"));

      final difference = engine.parse(["10", "-", "2"]);
      expect(engine.evaluate(difference), Decimal.parse("8.0"));

      final multiple = engine.parse(["10", "*", "2"]);
      expect(engine.evaluate(multiple), Decimal.parse("20.0"));

      final division = engine.parse(["10", "/", "2"]);
      expect(engine.evaluate(division), Decimal.parse("5.0"));
    });

    test("bracketed operations", () {
      final closed = engine.parse(["2", "+", "(", "3", ")"]);
      expect(engine.evaluate(closed), Decimal.parse("5.0"));

      final unclosed = engine.parse(["2", "+", "(", "-", "2", "/", "4"]);
      expect(engine.evaluate(unclosed), Decimal.parse("1.5"));
    });

    test("contextual percentage", () {
      final addPct = engine.parse(["10", "+", "10", "%"]);
      expect(engine.evaluate(addPct), Decimal.parse("11.0"));
    });

    test("non-contextual percentage", () {
      final unaryPct = engine.parse(["10", "%"]);
      expect(engine.evaluate(unaryPct), Decimal.parse("0.1"));

      final multPct = engine.parse(["10", "*", "10", "%"]);
      expect(engine.evaluate(multPct), Decimal.parse("1.0"));

      final implicit = engine.parse(["10", "%", "2"]);
      expect(engine.evaluate(implicit), Decimal.parse("0.2"));
    });

    test("trigonometric operations (with mode switch)", () {
      final degrees = engine.parse(["sin", "(", "30"]);
      expect(
        engine.evaluate(degrees, mode: MathMode.DEGREES),
        Decimal.parse("0.5"),
      );
      final radians = engine.parse(["sin", "(", "pi", "/", "6"]);
      expect(
        engine.evaluate(radians, mode: MathMode.RADIANS),
        Decimal.parse("0.5"),
      );
    });

    test("inverse trigonometric operations (with mode switch)", () {
      final degrees = engine.parse(["arcsin", "0.5"]);
      expect(
        engine.evaluate(degrees, mode: MathMode.DEGREES),
        Decimal.parse("30"),
      );
    });

    test("factorial of zero", () {
      final expression = engine.parse(["0", "!"]);
      expect(engine.evaluate(expression), Decimal.parse("1.0"));
    });

    test("small factorials (0 <= x < 999)", () {
      final expression = engine.parse(["4", "!"]);
      expect(engine.evaluate(expression), Decimal.parse("24.0"));
    });

    test("large factorials (999+)", () {
      final expression = engine.parse(["999", "!"]);
      final result = engine.evaluate(expression).toStringAsExponential(12);
      expect(result.substring(0, 12), "4.0238726007");
      expect(true, result.endsWith("+2564"));
    });

    test("small chain factorials", () {
      final expression = engine.parse(["4", "!", "!"]);
      expect(
        engine.evaluate(expression),
        Decimal.parse("620448401733239439360000"),
      );
    });

    test("large chain factorials", () {
      final expression = engine.parse(["6", "!", "!"]);
      final result = engine.evaluate(expression).toString();
      expect(result.substring(0, 12), "260121894356");
      expect(1747, result.length);
    });

    test("constants", () {
      final euler = engine.parse(["e"]);
      expect(engine.evaluate(euler), Decimal.parse(Math.e.toString()));

      final pi = engine.parse(["pi"]);
      expect(engine.evaluate(pi), Decimal.parse(Math.pi.toString()));
    });

    test("simple powers", () {
      final power1 = engine.parse(["2", "^", "2.0"]);
      expect(engine.evaluate(power1), Decimal.parse("4.0"));

      final power2 = engine.parse(["2", "^", "-", "2"]);
      expect(engine.evaluate(power2), Decimal.parse("0.25"));

      final power3 = engine.parse(["2", "^", "0.5"]);
      final result = engine.evaluate(power3);
      expect(true, result.toString().startsWith("1.4142"));
    });

    test("chained powers", () {
      final chained = engine.parse(["2", "^", "2", "^", "2", "^", "2"]);
      expect(engine.evaluate(chained), Decimal.parse("65536.0"));
    });

    test("power + factorial + negation ordering", () {
      final expression = engine.parse(["2", "^", "-", "3", "!"]);
      expect(engine.evaluate(expression), Decimal.parse("0.015625"));
    });

    test("logarithms", () {
      final log = engine.parse(["2", "^", "log", "100"]);
      expect(engine.evaluate(log), Decimal.parse("4.0"));

      final ln = engine.parse(["ln", "e", "^", "2"]);
      expect(engine.evaluate(ln), Decimal.parse("2.0"));
    });

    test("exponentials of e", () {
      final exp = engine.parse(["exp", "2"]);
      expect(true, engine.evaluate(exp).toString().startsWith("7.3890"));
    });

    test("square root", () {
      final root = engine.parse(["sqrt", "4"]);
      expect(engine.evaluate(root), Decimal.parse("2"));
    });

    test("AST print", () {
      final astTest = engine.parse(["-", "4", "+", "2", "%"]);
      expect(astTest.printAST(), "((NEGATE 4) ADDITION (2% of (NEGATE 4)))");
    });
  });

  group("Error Tests", () {
    final engine = MathEngine();

    test("custom error message", () {
      try {
        throw CalculatorException("Custom Error");
      } on CalculatorException catch (e) {
        expect(e.message, "Custom Error");
        expect(e.toString(), "MathEngine Exception: Custom Error");
      }
    });

    test("division by zero", () {
      final expression = engine.parse(["2", "/", "0"]);
      try {
        engine.evaluate(expression);
      } on CalculatorException catch (e) {
        expect(e.message, "Division By Zero");
      }
    });

    test("factorial of fraction", () {
      final expression = engine.parse(["0.25", "!"]);
      try {
        engine.evaluate(expression);
      } on CalculatorException catch (e) {
        expect(e.message, "Factorial of fraction");
      }
    });

    test("factorial of negative", () {
      final expression = engine.parse(["(", "-", "1", ")", "!"]);
      try {
        engine.evaluate(expression);
      } on CalculatorException catch (e) {
        expect(e.message, "Factorial of negative");
      }
    });

    test("extremely large factorials (4000+)", () {
      final expression = engine.parse(["4000", "!"]);
      try {
        engine.evaluate(expression);
      } on CalculatorException catch (e) {
        expect(e.message, "Factorial too large");
      }
    });

    test("logarithm of zero", () {
      final expression = engine.parse(["log", "0"]);
      try {
        engine.evaluate(expression);
      } on CalculatorException catch (e) {
        expect(e.message, "Domain Error");
      }
    });

    test("square root of negative", () {
      final root = engine.parse(["sqrt", "-", "1"]);
      try {
        engine.evaluate(root);
      } on CalculatorException catch (e) {
        expect(e.message, "Imaginary Number");
      }
    });
  });
}
