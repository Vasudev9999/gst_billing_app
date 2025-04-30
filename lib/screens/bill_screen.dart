import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/gst_calculator.dart';

class BillScreen extends StatelessWidget {
  final List<Product> products;

  const BillScreen({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    double subtotal = 0.0;
    double totalCGST = 0.0;
    double totalSGST = 0.0;
    double grandTotal = 0.0;

    for (var product in products) {
      subtotal += product.price;
      totalCGST += product.cgst;
      totalSGST += product.sgst;
      grandTotal += product.totalPrice;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Preview')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TATA Retail Solutions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('GST Invoice', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateTime.now().toString().substring(0, 10)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Items list now shown via CartScreen instead
            const Text(
              'Bill Items (Please use Cart Screen)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Bill Summary
            const Text(
              'Bill Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Subtotal',
              GstCalculator.formatCurrency(subtotal),
            ),
            _buildSummaryRow('CGST', GstCalculator.formatCurrency(totalCGST)),
            _buildSummaryRow('SGST', GstCalculator.formatCurrency(totalSGST)),
            const Divider(),
            _buildSummaryRow(
              'Grand Total',
              GstCalculator.formatCurrency(grandTotal),
              isTotal: true,
            ),

            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Product Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
