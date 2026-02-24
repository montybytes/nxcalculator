import "dart:math";

import "package:decimal/decimal.dart";
import "package:decimal/intl.dart";
import "package:flutter/foundation.dart";
import "package:intl/intl.dart";
import "package:nxcalculator/models/setting.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/settings.dart";

extension StringCasingExtension on String {
  String capitalize() {
    if (trim().isEmpty) {
      return this;
    }

    return toLowerCase()
        .split(RegExp(r"\s+"))
        .map((word) {
          if (word.isEmpty) {
            return word;
          }
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(" ");
  }
}

String getFormattedResult(
  String result, {
  int maxIntegerDigits = 13,
  int maxFractionDigits = 12,
  bool noSeparator = false,
  SettingsRepository? settings,
}) {
  final number = Decimal.tryParse(result);

  if (result.isEmpty || number == null) {
    return result;
  }

  final format = NumberFormat.decimalPattern();
  late final DecimalFormatter formatter;

  final abs = number.abs();

  final integerLength = abs.truncate().toString().length;

  final isNegative = number < Decimal.zero;
  final sign = isNegative ? "-" : "";

  if (integerLength > maxIntegerDigits) {
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

    final mantissa = Decimal.parse(
      "${digits[0]}.${digits.substring(1, min(digits.length, fractionDigits))}",
    );

    format.maximumFractionDigits = fractionDigits;
    format.minimumFractionDigits = 0;

    if (noSeparator) {
      format.turnOffGrouping();
    }

    formatter = DecimalFormatter(format);

    return _getFormattedNumber(
      "$sign${formatter.format(mantissa)}E$exponent",
      settings,
    );
  }

  if (abs > Decimal.zero && abs < Decimal.one) {
    final raw = abs.toString().replaceAll("0.", "");

    final firstNonZero = raw.split("").indexWhere((char) => char != "0");

    if (firstNonZero > 2) {
      final significant = raw.substring(firstNonZero);
      final digits = significant.substring(
        0,
        significant.length.clamp(0, maxFractionDigits),
      );

      final exponent = -(firstNonZero + 1);

      final fractionDigits = (maxFractionDigits - exponent.toString().length)
          .clamp(0, maxFractionDigits);

      final mantissa = Decimal.parse(
        "${digits[0]}.${digits.substring(1, min(digits.length, fractionDigits))}",
      );

      format.maximumFractionDigits = fractionDigits;
      format.minimumFractionDigits = 0;

      if (noSeparator) {
        format.turnOffGrouping();
      }

      formatter = DecimalFormatter(format);

      return _getFormattedNumber(
        "$sign${formatter.format(mantissa)}E$exponent",
        settings,
      );
    }
  }

  final fractionDigits = (maxFractionDigits - integerLength).clamp(
    0,
    maxFractionDigits,
  );

  format.maximumFractionDigits = fractionDigits;
  format.minimumFractionDigits = 0;

  if (noSeparator) {
    format.turnOffGrouping();
  }

  formatter = DecimalFormatter(format);
  return _getFormattedNumber(
    formatter.format(Decimal.parse(number.toStringAsFixed(fractionDigits))),
    settings,
  );
}

String getSystemDecimalSeparator() {
  final locale = PlatformDispatcher.instance.locale.toLanguageTag();
  final symbols = NumberFormat.decimalPattern(locale).symbols;

  return symbols.DECIMAL_SEP;
}

String getSystemGroupingSeparator() {
  final locale = PlatformDispatcher.instance.locale.toLanguageTag();
  final symbols = NumberFormat.decimalPattern(locale).symbols;

  return symbols.GROUP_SEP;
}

String _getFormattedNumber(String number, SettingsRepository? settings) {
  final groupingSeparator = settings?.get(groupingSeparatorSetting);
  final decimalSeparator = settings?.get(decimalSeparatorSetting);

  final parts = number.split(".");

  final groupSep = mapGroupingSeparator(
    groupingSeparator ?? GroupingSeparator.system,
  );
  final decimalSep = mapDecimalSeparator(
    decimalSeparator ?? DecimalSeparator.system,
  );

  if (parts.length > 1) {
    return "${parts[0].replaceAll(",", groupSep)}$decimalSep${parts[1]}";
  }

  if (parts.length == 1 && parts[0].contains(",")) {
    return parts[0].replaceAll(",", groupSep);
  }

  return number;
}

String mapGroupingSeparator(GroupingSeparator separator) {
  switch (separator) {
    case GroupingSeparator.comma:
      return ",";
    case GroupingSeparator.dot:
      return ".";
    case GroupingSeparator.space:
      return " ";
    case GroupingSeparator.system:
      return getSystemGroupingSeparator();
  }
}

String mapDecimalSeparator(DecimalSeparator separator) {
  switch (separator) {
    case DecimalSeparator.dot:
      return ".";
    case DecimalSeparator.comma:
      return ",";
    case DecimalSeparator.system:
      return getSystemDecimalSeparator();
  }
}
