// ignore_for_file: constant_identifier_names

import "package:decimal/decimal.dart";
import "package:nxcalculator/backend/exception.dart";
import "package:nxcalculator/backend/nodes.dart";

class MathEngine {
  List<String> _tokens = [];

  Node parse(List<String> expression) {
    var unclosedBrackets = 0;

    for (final token in expression) {
      if (token == "(") {
        unclosedBrackets++;
      }
      if (token == ")") {
        unclosedBrackets--;
      }
    }

    _tokens = expression;
    _tokens.addAll(List.filled(unclosedBrackets, ")"));

    return _parseExpression(0).node;
  }

  Decimal evaluate(Node expression, {MathMode mode = MathMode.RADIANS}) {
    return expression.compute(mode: mode);
  }

  ParseResult _parseExpression(int index) {
    var left = _parseTerm(index);

    while (left.next < _tokens.length) {
      final op = _tokens[left.next];

      if (op == "+" || op == "-") {
        ParseResult right;

        final powerCandidate = _parsePower(left.next + 1);

        if (powerCandidate.next < _tokens.length &&
            _tokens[powerCandidate.next] == "%") {
          var isPostfix = true;

          if (powerCandidate.next + 1 < _tokens.length) {
            isPostfix = !_isFactorStarter(_tokens[powerCandidate.next + 1]);
          }

          if (isPostfix) {
            right = ParseResult(
              node: PercentNode(value: powerCandidate.node, base: left.node),
              next: powerCandidate.next + 1,
            );
          } else {
            right = _parseTerm(left.next + 1);
          }
        } else {
          right = _parseTerm(left.next + 1);
        }

        left = ParseResult(
          node: BinaryNode(
            type: op == "+"
                ? BinaryNodeType.ADDITION
                : BinaryNodeType.SUBTRACTION,
            left: left.node,
            right: right.node,
          ),
          next: right.next,
        );
      } else {
        break;
      }
    }

    return left;
  }

  ParseResult _parseTerm(int index) {
    var left = _parsePower(index);

    while (left.next < _tokens.length) {
      final op = _tokens[left.next];

      if (op == "*" || op == "/") {
        final right = _parsePower(left.next + 1);

        left = ParseResult(
          node: BinaryNode(
            type: op == "*"
                ? BinaryNodeType.MULTIPLICATION
                : BinaryNodeType.DIVISION,
            left: left.node,
            right: right.node,
          ),
          next: right.next,
        );
      } else if (op == "%") {
        if (left.next + 1 < _tokens.length &&
            _isFactorStarter(_tokens[left.next + 1])) {
          final right = _parsePower(left.next + 1);
          left = ParseResult(
            node: PercentNode(value: right.node, base: left.node),
            next: right.next,
          );
          continue;
        }
        break;
      } else {
        break;
      }
    }

    if (left.next < _tokens.length && _tokens[left.next] == "%") {
      if (left.next + 1 >= _tokens.length ||
          !_isFactorStarter(_tokens[left.next + 1])) {
        left = ParseResult(
          node: PercentNode(
            value: left.node,
            base: LiteralNode(literal: "1"),
          ),
          next: left.next + 1,
        );
      }
    }

    return left;
  }

  ParseResult _parsePower(int index) {
    final left = _parseFactor(index);

    if (left.next < _tokens.length && _tokens[left.next] == "^") {
      final right = _parsePower(left.next + 1);
      return ParseResult(
        node: BinaryNode(
          type: BinaryNodeType.POWER,
          left: left.node,
          right: right.node,
        ),
        next: right.next,
      );
    }

    return left;
  }

  ParseResult _parseFactor(int index) {
    var result = _parseUnary(index);

    while (result.next < _tokens.length && _tokens[result.next] == "!") {
      result = ParseResult(
        node: UnaryNode(type: UnaryNodeType.FACTORIAL, operand: result.node),
        next: result.next + 1,
      );
    }

    return result;
  }

  ParseResult _parseUnary(int index) {
    if (index >= _tokens.length) {
      throw CalculatorException("Format Error");
    }

    final token = _tokens[index];

    if (_isUnaryOperator(token)) {
      final result = _parsePower(index + 1);
      return ParseResult(
        node: UnaryNode(type: _mapUnary(token), operand: result.node),
        next: result.next,
      );
    }

    return _parsePrimary(index);
  }

  ParseResult _parsePrimary(int index) {
    final token = _tokens[index];

    if (token == "(") {
      final inner = _parseExpression(index + 1);
      return ParseResult(node: inner.node, next: inner.next + 1);
    }

    return ParseResult(
      node: LiteralNode(literal: token),
      next: index + 1,
    );
  }

  bool _isFactorStarter(String token) {
    return token == "(" ||
        token == "pi" ||
        token == "e" ||
        _isUnaryOperator(token) ||
        RegExp(r"^\d").hasMatch(token);
  }

  bool _isUnaryOperator(String token) {
    return token == "-" ||
        token == "ln" ||
        token == "log" ||
        token == "exp" ||
        token == "sin" ||
        token == "cos" ||
        token == "tan" ||
        token == "sqrt" ||
        token == "arcsin" ||
        token == "arccos" ||
        token == "arctan";
  }

  UnaryNodeType _mapUnary(String token) {
    switch (token) {
      case "-":
        return UnaryNodeType.NEGATE;
      case "sin":
        return UnaryNodeType.SIN;
      case "cos":
        return UnaryNodeType.COS;
      case "tan":
        return UnaryNodeType.TAN;
      case "arcsin":
        return UnaryNodeType.ARCSIN;
      case "arccos":
        return UnaryNodeType.ARCCOS;
      case "arctan":
        return UnaryNodeType.ARCTAN;
      case "log":
        return UnaryNodeType.LOG;
      case "ln":
        return UnaryNodeType.LN;
      case "exp":
        return UnaryNodeType.EXPONENTIAL;
      case "sqrt":
        return UnaryNodeType.ROOT;
      default:
        throw CalculatorException("Unknown token: $token");
    }
  }
}

class ParseResult {
  final Node node;
  final int next;

  ParseResult({required this.node, required this.next});
}
