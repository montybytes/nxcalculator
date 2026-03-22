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

String getFormattedToken(
  String token, {
  int maxIntegerDigits = 13,
  int maxFractionDigits = 12,
  bool noGrouping = false,
  SettingsRepository? settings,
}) {
  final number = Decimal.tryParse(token);

  final groupSep = settings?.get(groupingSeparator);
  final decimalSep = settings?.get(decimalSeparator);

  if (token == ".") {
    return mapDecimalSeparator(decimalSep);
  }

  if (token.isEmpty || number == null) {
    return token;
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

    if (noGrouping) {
      format.turnOffGrouping();
    }

    formatter = DecimalFormatter(format);

    return _getFormattedNumber(
      "$sign${formatter.format(mantissa)}E$exponent",
      groupingSep: groupSep,
      decimalSep: decimalSep,
    );
  }

  if (abs > Decimal.zero && abs < Decimal.one) {
    final raw = abs.toString().replaceAll("0.", "");

    final firstNonZero = raw.split("").indexWhere((char) => char != "0");

    if (firstNonZero > 6) {
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

      if (noGrouping) {
        format.turnOffGrouping();
      }

      formatter = DecimalFormatter(format);

      return _getFormattedNumber(
        "$sign${formatter.format(mantissa)}E$exponent",
        groupingSep: groupSep,
        decimalSep: decimalSep,
      );
    }
  }

  final fractionDigits = (maxFractionDigits - integerLength).clamp(
    0,
    maxFractionDigits,
  );

  format.maximumFractionDigits = fractionDigits;
  format.minimumFractionDigits = 0;

  if (noGrouping) {
    format.turnOffGrouping();
  }

  formatter = DecimalFormatter(format);
  return _getFormattedNumber(
    formatter.format(Decimal.parse(number.toStringAsFixed(fractionDigits))),
    groupingSep: groupSep,
    decimalSep: decimalSep,
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

String mapGroupingSeparator(GroupingSeparator? separator) {
  switch (separator) {
    case GroupingSeparator.comma:
      return ",";
    case GroupingSeparator.dot:
      return ".";
    case GroupingSeparator.space:
      return " ";
    default:
      return getSystemGroupingSeparator();
  }
}

String mapDecimalSeparator(DecimalSeparator? separator) {
  switch (separator) {
    case DecimalSeparator.dot:
      return ".";
    case DecimalSeparator.comma:
      return ",";
    default:
      return getSystemDecimalSeparator();
  }
}

String _getFormattedNumber(
  String number, {
  GroupingSeparator? groupingSep,
  DecimalSeparator? decimalSep,
}) {
  final parts = number.split(".");

  final gSep = mapGroupingSeparator(groupingSep);
  final dSep = mapDecimalSeparator(decimalSep);

  if (parts.length > 1) {
    return "${parts[0].replaceAll(",", gSep)}$dSep${parts[1]}";
  }

  if (parts.length == 1 && parts[0].contains(",")) {
    return parts[0].replaceAll(",", gSep);
  }

  return number;
}
