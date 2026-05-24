/// Converts an integer amount to Indian number words (Lakh/Crore system).
/// Examples:
///   5100      → "Five Thousand One Hundred Only"
///   150000    → "One Lakh Fifty Thousand Only"
///   10000000  → "One Crore Only"
///   25650     → "Twenty Five Thousand Six Hundred Fifty Only"

const List<String> _ones = [
  '',
  'One',
  'Two',
  'Three',
  'Four',
  'Five',
  'Six',
  'Seven',
  'Eight',
  'Nine',
  'Ten',
  'Eleven',
  'Twelve',
  'Thirteen',
  'Fourteen',
  'Fifteen',
  'Sixteen',
  'Seventeen',
  'Eighteen',
  'Nineteen',
];

const List<String> _tens = [
  '',
  '',
  'Twenty',
  'Thirty',
  'Forty',
  'Fifty',
  'Sixty',
  'Seventy',
  'Eighty',
  'Ninety',
];

/// Converts a number < 1000 to words.
String _belowThousand(int n) {
  if (n == 0) return '';
  if (n < 20) return _ones[n];
  if (n < 100) {
    final t = _tens[n ~/ 10];
    final o = n % 10 == 0 ? '' : ' ${_ones[n % 10]}';
    return '$t$o';
  }
  final h = '${_ones[n ~/ 100]} Hundred';
  final rem = n % 100;
  if (rem == 0) return h;
  return '$h ${_belowThousand(rem)}';
}

/// Main conversion function. Appends "Only" automatically.
String convertToIndianWords(int amount) {
  if (amount == 0) return 'Zero Only';

  final parts = <String>[];
  int n = amount;

  // Crores (10,000,000+)
  if (n >= 10000000) {
    parts.add('${_belowThousand(n ~/ 10000000)} Crore');
    n %= 10000000;
  }

  // Lakhs (100,000+)
  if (n >= 100000) {
    parts.add('${_belowThousand(n ~/ 100000)} Lakh');
    n %= 100000;
  }

  // Thousands (1,000+)
  if (n >= 1000) {
    parts.add('${_belowThousand(n ~/ 1000)} Thousand');
    n %= 1000;
  }

  // Remainder < 1000
  if (n > 0) {
    parts.add(_belowThousand(n));
  }

  return '${parts.join(' ')} Only';
}

/// Returns raw words without "Only" suffix — used for display in the text field.
String convertToIndianWordsRaw(int amount) {
  if (amount == 0) return '';
  final withOnly = convertToIndianWords(amount);
  // strip trailing " Only"
  return withOnly.endsWith(' Only')
      ? withOnly.substring(0, withOnly.length - 5)
      : withOnly;
}
