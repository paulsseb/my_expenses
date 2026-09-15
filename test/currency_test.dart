import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_expenses/utils/currency.dart';

void main() {
  group('formatAmount', () {
    test('groups thousands', () {
      expect(formatAmount(1000), "1,000");
      expect(formatAmount(1234567), "1,234,567");
      expect(formatAmount(999), "999");
      expect(formatAmount(0), "0");
      expect(formatAmount(null), "0");
    });

    test('keeps two decimals only when there is a fraction', () {
      expect(formatAmount(1500.0), "1,500");
      expect(formatAmount(1500.5), "1,500.50");
      expect(formatAmount(1234567.89), "1,234,567.89");
    });
  });

  test('formatCurrency prefixes the currency label', () {
    expect(formatCurrency(25000), "Ugx. 25,000");
  });

  test('parseAmount reads grouped text back', () {
    expect(parseAmount("1,234,567"), 1234567);
    expect(parseAmount("1,500.50"), 1500.5);
    expect(parseAmount(""), null);
    expect(parseAmount("abc"), null);
  });

  group('groupAmountInput', () {
    test('groups as digits are typed', () {
      expect(groupAmountInput("1"), "1");
      expect(groupAmountInput("1234"), "1,234");
      expect(groupAmountInput("1,234,567"), "1,234,567");
    });

    test('drops stray characters and leading zeros', () {
      expect(groupAmountInput("1a2b3c4"), "1,234");
      expect(groupAmountInput("007"), "7");
      expect(groupAmountInput(""), "");
      expect(groupAmountInput("abc"), "");
    });

    test('keeps a single decimal point, capped at two digits', () {
      expect(groupAmountInput("1500.5"), "1,500.5");
      expect(groupAmountInput("1500.567"), "1,500.56");
      expect(groupAmountInput("1.2.3"), "1.23");
      expect(groupAmountInput("."), ".");
    });
  });

  group('ThousandsSeparatorInputFormatter', () {
    const formatter = ThousandsSeparatorInputFormatter();

    TextEditingValue typed(String text) => TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));

    test('groups the text and keeps the caret at the end', () {
      var result = formatter.formatEditUpdate(typed("123"), typed("1234"));
      expect(result.text, "1,234");
      expect(result.selection.baseOffset, 5);
    });

    test('keeps the caret in place when editing mid-string', () {
      // Caret after "12" in "12345" -> grouped "12,345", caret still after "12".
      var result = formatter.formatEditUpdate(
        typed("1234"),
        const TextEditingValue(
            text: "12345", selection: TextSelection.collapsed(offset: 2)),
      );
      expect(result.text, "12,345");
      expect(result.selection.baseOffset, 2);
    });

    test('handles deleting everything', () {
      var result = formatter.formatEditUpdate(typed("1,234"), typed(""));
      expect(result.text, "");
      expect(result.selection.baseOffset, 0);
    });
  });
}
