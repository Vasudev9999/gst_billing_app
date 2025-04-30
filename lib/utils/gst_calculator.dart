class GstCalculator {
  static double calculateCGST(double price, double gstRate) {
    return (price * gstRate) / 2;
  }

  static double calculateSGST(double price, double gstRate) {
    return (price * gstRate) / 2;
  }

  static double calculateTotalPrice(double price, double gstRate) {
    return price +
        calculateCGST(price, gstRate) +
        calculateSGST(price, gstRate);
  }

  // Format currency to 2 decimal places
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Format percentage for display
  static String formatPercentage(double rate) {
    return '${(rate * 100).toStringAsFixed(0)}%';
  }
}
