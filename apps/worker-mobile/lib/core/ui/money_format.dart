/// Formats an API decimal string ("125000.00") for display, without ever
/// converting it to a double: "125 000 ֏". Zero fractions are dropped, so
/// "1500.50" becomes "1 500.50 ֏".
String formatMoney(String amount, {String currency = 'AMD'}) {
  final negative = amount.startsWith('-');
  final parts = (negative ? amount.substring(1) : amount).split('.');
  final whole = parts[0].isEmpty ? '0' : parts[0];
  final fraction = parts.length > 1 ? parts[1] : '';

  final grouped = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) grouped.write(' ');
    grouped.write(whole[i]);
  }
  final showFraction = fraction.isNotEmpty && int.tryParse(fraction) != 0;
  final symbol = currency == 'AMD' ? '֏' : currency;
  return '${negative ? '-' : ''}$grouped'
      '${showFraction ? '.${fraction.padRight(2, '0')}' : ''} $symbol';
}
