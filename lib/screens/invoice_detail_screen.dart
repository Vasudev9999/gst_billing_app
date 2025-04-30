import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../utils/gst_calculator.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({Key? key, required this.invoice})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${invoice.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Print functionality will be added in future versions',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Header
            const Text(
              'TATA Retail Solutions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'GST Invoice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Invoice #: ${invoice.invoiceNumber}'),
                Text('Date: ${invoice.formattedDate}'),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),

            // Invoice Items
            const Text(
              'Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Invoice Item Headers
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Item',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Price',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'GST',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Invoice Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoice.products.length,
              itemBuilder: (context, index) {
                final product = invoice.products[index];
                return _buildInvoiceItemRow(product, index);
              },
            ),

            const Divider(),

            // Invoice Summary
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Subtotal:',
              GstCalculator.formatCurrency(invoice.subtotal),
            ),
            _buildSummaryRow(
              'CGST:',
              GstCalculator.formatCurrency(invoice.totalCGST),
            ),
            _buildSummaryRow(
              'SGST:',
              GstCalculator.formatCurrency(invoice.totalSGST),
            ),
            const Divider(),
            _buildSummaryRow(
              'Grand Total:',
              GstCalculator.formatCurrency(invoice.totalAmount),
              isTotal: true,
            ),

            const SizedBox(height: 30),

            // Thank You Note
            const Center(
              child: Text(
                'Thank you for your business!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItemRow(Product product, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '${index + 1}. ${product.name}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(GstCalculator.formatCurrency(product.price)),
          ),
          Expanded(
            flex: 2,
            child: Text('${GstCalculator.formatPercentage(product.gstRate)}'),
          ),
          Expanded(
            flex: 2,
            child: Text(
              GstCalculator.formatCurrency(product.totalPrice),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
