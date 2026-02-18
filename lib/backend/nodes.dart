// ignore_for_file: constant_identifier_names, library_prefixes

import "dart:math" as Math;

import "package:decimal/decimal.dart";
import "package:nxcalculator/backend/exception.dart";

enum MathMode { DEGREES, RADIANS }

enum UnaryNodeType {
  NEGATE,
  FACTORIAL,
  SIN,
  COS,
  TAN,
  ARCCOS,
  ARCSIN,
  ARCTAN,
  LOG,
  LN,
  EXPONENTIAL,
  ROOT,
}

enum BinaryNodeType { DIVISION, MULTIPLICATION, ADDITION, SUBTRACTION, POWER }

abstract class Node {
  Decimal compute({MathMode mode = MathMode.RADIANS});
  String printAST();
}

class LiteralNode extends Node {
  final String literal;

  LiteralNode({required this.literal});

  @override
  Decimal compute({MathMode mode = MathMode.RADIANS}) {
    if (literal == "e") {
      return _toDecimal(Math.e);
    }
    if (literal == "pi") {
      return _toDecimal(Math.pi);
    }
    return Decimal.parse(literal);
  }

  @override
  String printAST() => literal;
}

class UnaryNode extends Node {
  final UnaryNodeType type;
  final Node operand;

  UnaryNode({required this.type, required this.operand});

  @override
  Decimal compute({MathMode mode = MathMode.RADIANS}) {
    final x = operand.compute();
    switch (type) {
      case UnaryNodeType.NEGATE:
        return -x;

      case UnaryNodeType.EXPONENTIAL:
        final e = Math.e;

        final digitCountEstimate =
            x * _toDecimal(Math.log(e.abs().toDouble()) / Math.ln10);

        if (digitCountEstimate > Decimal.fromInt(130)) {
          throw CalculatorException("Can't calculate");
        }

        final exp = x.toBigInt();

        if (exp == BigInt.zero) {
          return Decimal.one;
        }

        if (x == Decimal.fromBigInt(exp)) {
          var result = Decimal.one;

          var current = _toDecimal(e);
          var ex = exp.abs();

          while (ex > BigInt.zero) {
            if (ex.isOdd) {
              result *= current;
            }
            current *= current;
            ex >>= 1;
          }

          if (exp.isNegative) {
            return (Decimal.one / result).toDecimal(
              scaleOnInfinitePrecision: 28,
            );
          }
          return result;
        }

        final result = Math.pow(e, x.toDouble()).toDouble();

        if (result.isInfinite) {
          throw CalculatorException("Can't calculate");
        }

        return _toDecimal(result);

      case UnaryNodeType.ROOT:
        if (x < Decimal.zero) {
          throw CalculatorException("Imaginary Number");
        }
        return _toDecimal(Math.sqrt(_toDouble(x)));

      case UnaryNodeType.SIN:
      case UnaryNodeType.COS:
      case UnaryNodeType.TAN:
        double r = 0;

        if (type == UnaryNodeType.SIN) {
          r = Math.sin(_angleToRadians(x, mode));
        }
        if (type == UnaryNodeType.COS) {
          r = Math.cos(_angleToRadians(x, mode));
        }
        if (type == UnaryNodeType.TAN) {
          r = Math.tan(_angleToRadians(x, mode));
        }
        if (r.isNaN) {
          throw CalculatorException("Domain Error");
        }
        return _toDecimal((r * 1e12).round() / 1e12);

      case UnaryNodeType.ARCSIN:
      case UnaryNodeType.ARCCOS:
      case UnaryNodeType.ARCTAN:
        double result = 0;

        if (type == UnaryNodeType.ARCSIN) {
          result = _radiansToAngle(Math.asin(_toDouble(x)), mode);
        }
        if (type == UnaryNodeType.ARCCOS) {
          result = _radiansToAngle(Math.acos(_toDouble(x)), mode);
        }
        if (type == UnaryNodeType.ARCTAN) {
          result = _radiansToAngle(Math.atan(_toDouble(x)), mode);
        }
        if (result.isNaN) {
          throw CalculatorException("Domain Error");
        }

        return _toDecimal((result * 1e12).round() / 1e12);

      case UnaryNodeType.LOG:
      case UnaryNodeType.LN:
        double result = 0;

        if (x <= Decimal.zero) {
          throw CalculatorException("Domain Error");
        }
        if (type == UnaryNodeType.LOG) {
          result = (Math.log(_toDouble(x)) / Math.ln10);
        }
        if (type == UnaryNodeType.LN) {
          result = (Math.log(_toDouble(x)));
        }

        return _toDecimal(result);

      case UnaryNodeType.FACTORIAL:
        if (x < Decimal.zero) {
          throw CalculatorException("Factorial of negative");
        }

        if (x.scale != 0) {
          throw CalculatorException("Factorial of fraction");
        }

        if (x == Decimal.zero || x == Decimal.one) {
          return Decimal.one;
        }

        if (x > Decimal.fromInt(2999)) {
          throw CalculatorException("Factorial too large");
        }

        Decimal trueFactorial(Decimal x) {
          // Binary splitting method
          Decimal productRange(BigInt low, BigInt high) {
            if (low == high) {
              return Decimal.fromBigInt(low);
            }

            if (high - low == BigInt.one) {
              return Decimal.fromBigInt(low) * Decimal.fromBigInt(high);
            }

            final BigInt mid = (low + high) >> 1;

            return productRange(low, mid) *
                productRange(mid + BigInt.one, high);
          }

          return productRange(BigInt.one, x.toBigInt());
        }

        Decimal approximatedFactorial(Decimal x) {
          // Approximation using Sterling's Formula (Ramanujan Version)
          final n = x.toDouble();

          final logFactorial =
              0.5 * Math.log(Math.pi) +
              n * (Math.log(n) - 1.0) +
              (1.0 / 6.0) *
                  Math.log(8 * n * n * n + 4 * n * n + n + 1.0 / 30.0);

          final log10Value = logFactorial / Math.ln10;

          final exponent = log10Value.floor();
          final fractional = log10Value - exponent;

          final leading = Math.pow(10, fractional + 12 - 1);

          final leadingInt = leading.floor().toString().replaceRange(1, 1, ".");

          return Decimal.parse("${leadingInt}E$exponent");
        }

        if (x >= Decimal.fromInt(999)) {
          return approximatedFactorial(x);
        }

        return trueFactorial(x);
    }
  }

  @override
  String printAST() => "(${type.name} ${operand.printAST()})";
}

class BinaryNode extends Node {
  final BinaryNodeType type;
  final Node left;
  final Node right;

  BinaryNode({required this.type, required this.left, required this.right});

  @override
  Decimal compute({MathMode mode = MathMode.RADIANS}) {
    final l = left.compute();
    final r = right.compute();

    switch (type) {
      case BinaryNodeType.POWER:
        if (l == Decimal.zero) {
          if (r < Decimal.zero) {
            throw CalculatorException("Division By zero");
          }
          return Decimal.zero;
        }

        if (l < Decimal.zero && r.isInteger == false) {
          throw CalculatorException("Math Error");
        }

        if (r == Decimal.zero) {
          return Decimal.one;
        }

        final digitCountEstimate =
            r * _toDecimal(Math.log(l.abs().toDouble()) / Math.ln10);

        if (l.isInteger == false) {
          if (digitCountEstimate > Decimal.fromInt(310)) {
            throw CalculatorException("Can't calculate");
          }
        }

        if (digitCountEstimate > Decimal.fromInt(20000)) {
          throw CalculatorException("Can't calculate");
        }

        final exp = r.toBigInt();

        if (r == Decimal.fromBigInt(exp)) {
          if (exp == BigInt.zero) {
            return Decimal.one;
          }

          var result = Decimal.one;

          var current = l;
          var e = exp.abs();

          while (e > BigInt.zero) {
            if (e.isOdd) {
              result *= current;
            }
            current *= current;
            e >>= 1;
          }

          if (exp.isNegative) {
            return (Decimal.one / result).toDecimal(
              scaleOnInfinitePrecision: 28,
            );
          }

          return result;
        }

        final result = Math.pow(_toDouble(l), _toDouble(r)).toDouble();

        if (result.isInfinite) {
          throw CalculatorException("Can't calculate");
        }

        return _toDecimal(result);

      case BinaryNodeType.ADDITION:
        return l + r;

      case BinaryNodeType.SUBTRACTION:
        return l - r;

      case BinaryNodeType.MULTIPLICATION:
        return l * r;

      case BinaryNodeType.DIVISION:
        if (r == Decimal.zero) {
          throw CalculatorException("Division By Zero");
        }
        return (l / r).toDecimal(scaleOnInfinitePrecision: 28);
    }
  }

  @override
  String printAST() => "(${left.printAST()} ${type.name} ${right.printAST()})";
}

class PercentNode extends Node {
  final Node base;
  final Node value;

  PercentNode({required this.value, required this.base});

  @override
  Decimal compute({MathMode mode = MathMode.RADIANS}) {
    final Decimal b = base.compute();
    final Decimal v = value.compute();

    return b *
        (v / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 28);
  }

  @override
  String printAST() => "(${value.printAST()}% of ${base.printAST()})";
}

double _toDouble(Decimal x) {
  return x.toDouble();
}

Decimal _toDecimal(double x) {
  return Decimal.parse(x.toString());
}

double _angleToRadians(Decimal x, MathMode mode) {
  return mode == MathMode.DEGREES ? _toDouble(x) * Math.pi / 180 : _toDouble(x);
}

double _radiansToAngle(double x, MathMode mode) {
  return mode == MathMode.DEGREES ? x * 180 / Math.pi : x;
}
