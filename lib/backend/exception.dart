class CalculatorException implements Exception {
  final String message;

  const CalculatorException(this.message);

  @override
  String toString() {
    return "MathEngine Exception: $message";
  }
}
