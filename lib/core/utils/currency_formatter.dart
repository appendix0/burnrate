class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format a USD amount for display.
  /// e.g. 0.004 → "$0.004", 12.5 → "$12.50", 1234.5 → "$1,234.50"
  static String format(double amount) {
    if (amount == 0) return '\$0.00';

    if (amount < 0.01) {
      // Show up to 4 decimal places for micro-amounts
      return '\$${amount.toStringAsFixed(4)}';
    }

    // Manual thousands separator for amounts >= 1000
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
      count++;
    }
    final reversed = buffer.toString().split('').reversed.join();
    return '\$$reversed.$decPart';
  }

  /// Compact form for cards: $1.2k, $340, etc.
  static String compact(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}k';
    }
    return format(amount);
  }
}
