import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Currency label shown next to every amount in the app.
const String currencySymbol = "Ugx.";

final NumberFormat _wholeFormat = NumberFormat("#,##0");
final NumberFormat _decimalFormat = NumberFormat("#,##0.00");

/// Short number format for chart axis labels, e.g. 1234567 -> "1.2M".
/// Charts take a [NumberFormat] rather than a formatting callback.
final NumberFormat compactNumberFormat = NumberFormat.compact();

/// Groups an amount with thousand separators, e.g. 1234567 -> "1,234,567".
/// Whole numbers stay whole; fractional amounts keep two decimals.
String formatAmount(num? value) {
  var amount = value ?? 0;
  return amount % 1 == 0
      ? _wholeFormat.format(amount)
      : _decimalFormat.format(amount);
}

/// A grouped amount with the currency label, e.g. "Ugx. 1,234,567".
String formatCurrency(num? value) => "$currencySymbol ${formatAmount(value)}";

/// Short form for tight spaces, e.g. 1234567 -> "1.2M".
String formatCompactAmount(num? value) => compactNumberFormat.format(value ?? 0);

/// Reads back a value typed into a grouped amount field.
double? parseAmount(String text) =>
    double.tryParse(text.replaceAll(",", "").trim());

/// Regroups whatever the user has typed so far, keeping it parseable:
/// digits only, a single decimal point and at most two decimals.
String groupAmountInput(String raw) {
  var cleaned = raw.replaceAll(RegExp(r"[^0-9.]"), "");

  var firstDot = cleaned.indexOf(".");
  if (firstDot != -1) {
    cleaned = cleaned.substring(0, firstDot + 1) +
        cleaned.substring(firstDot + 1).replaceAll(".", "");
  }
  if (cleaned.isEmpty) return "";

  var parts = cleaned.split(".");
  var whole = parts[0].replaceFirst(RegExp(r"^0+(?=\d)"), "");

  var grouped = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) grouped.write(",");
    grouped.write(whole[i]);
  }

  if (parts.length == 1) return grouped.toString();

  var fraction = parts[1];
  if (fraction.length > 2) fraction = fraction.substring(0, 2);
  return "$grouped.$fraction";
}

/// Keeps an amount text field grouped with commas while the user types.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  static final RegExp _meaningful = RegExp(r"[0-9.]");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var caret = newValue.selection.end.clamp(0, newValue.text.length);
    // Count from the right so inserted separators don't drag the caret around.
    var tailLength = newValue.text
        .substring(caret)
        .replaceAll(RegExp(r"[^0-9.]"), "")
        .length;

    var grouped = groupAmountInput(newValue.text);

    var offset = grouped.length;
    var counted = 0;
    while (offset > 0 && counted < tailLength) {
      offset--;
      if (_meaningful.hasMatch(grouped[offset])) counted++;
    }
    // Sit before a separator rather than after it, so backspace removes a
    // digit instead of a comma the formatter would immediately put back.
    if (offset > 0 && grouped[offset - 1] == ",") offset--;

    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
