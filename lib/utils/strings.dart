import "package:decimal/decimal.dart";
import "package:decimal/intl.dart";
import "package:flutter/foundation.dart";
import "package:intl/intl.dart";

String getFormattedResult(
  String result, {
  int maxIntegerDigits = 13,
  int maxFractionDigits = 12,
  bool noSeparator = false,
}) {
  final number = Decimal.tryParse(result);

  if (result.isEmpty || number == null) {
    return result;
  }

  late final NumberFormat format;
  late final DecimalFormatter formatter;

  final integerLength = number.abs().truncate().toString().length;
  final locale = PlatformDispatcher.instance.locale.toLanguageTag();

  if (integerLength > maxIntegerDigits) {
    final isNegative = number < Decimal.zero;
    final raw = number.abs().toString();

    late final String digits;
    late final int exponent;

    if (raw.contains(".")) {
      final parts = raw.split(".");
      final integer = parts[0];
      final fraction = parts[1];

      exponent = integer.length - 1;
      digits = integer + fraction;
    } else {
      digits = raw;
      exponent = raw.length - 1;
    }

    final fractionDigits = (maxFractionDigits - exponent.toString().length)
        .clamp(0, maxFractionDigits);

    final sign = isNegative ? "-" : "";
    final mantissa = Decimal.parse(
      "${digits[0]}.${digits.substring(1, fractionDigits)}",
    );

    format = NumberFormat.decimalPattern(locale);
    format.maximumFractionDigits = fractionDigits;
    format.minimumFractionDigits = 0;

    if (noSeparator) {
      format.turnOffGrouping();
    }

    formatter = DecimalFormatter(format);

    return "$sign${formatter.format(mantissa)}E$exponent";
  }

  final fractionDigits = (maxFractionDigits - integerLength).clamp(
    0,
    maxFractionDigits,
  );

  format = NumberFormat.decimalPattern(locale);
  format.maximumFractionDigits = fractionDigits;
  format.minimumFractionDigits = 0;

  if (noSeparator) {
    format.turnOffGrouping();
  }

  formatter = DecimalFormatter(format);
  return formatter.format(
    Decimal.parse(number.toStringAsFixed(fractionDigits)),
  );
}

String getLocaleDecimalSeparator() {
  final locale = PlatformDispatcher.instance.locale.toLanguageTag();
  final symbols = NumberFormat.decimalPattern(locale).symbols;

  return symbols.DECIMAL_SEP;
}
