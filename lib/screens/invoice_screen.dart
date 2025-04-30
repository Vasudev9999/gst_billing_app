import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../utils/gst_calculator.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../database/database_helper.dart';
import 'home_screen.dart';

class InvoiceScreen extends StatelessWidget {
  InvoiceScreen({Key? key}) : super(key: key);

  final String invoiceNumber =
      'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final currentDate = DateTime.now();
    final formattedDate =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
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
      body:
          cart.items.isEmpty
              ? const Center(child: Text('No items in cart'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice Header
                    const Text(
                      'TATA Retail Solutions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'GST Invoice',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Invoice #: $invoiceNumber'),
                        Text('Date: $formattedDate'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),

                    // Invoice Items
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final product = cart.items[index];
                        return _buildInvoiceItemRow(product, index);
                      },
                    ),

                    const Divider(),

                    // Invoice Summary
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Subtotal:',
                      GstCalculator.formatCurrency(cart.subtotal),
                    ),
                    _buildSummaryRow(
                      'CGST:',
                      GstCalculator.formatCurrency(cart.totalCGST),
                    ),
                    _buildSummaryRow(
                      'SGST:',
                      GstCalculator.formatCurrency(cart.totalSGST),
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Grand Total:',
                      GstCalculator.formatCurrency(cart.totalAmount),
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

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _saveInvoice(context, cart);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Text('Save Invoice'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _finishTransaction(context, cart);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Text('Finish'),
                          ),
                        ),
                      ],
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

  Future<void> _saveInvoice(BuildContext context, CartService cart) async {
    try {
      // Create invoice model
      final invoice = Invoice(
        invoiceNumber: invoiceNumber,
        dateTime: DateTime.now(),
        products: List.from(cart.items),
        subtotal: cart.subtotal,
        totalCGST: cart.totalCGST,
        totalSGST: cart.totalSGST,
        totalAmount: cart.totalAmount,
      );

      // Save to database
      await DatabaseHelper.instance.insertInvoice(invoice);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice saved successfully!')),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save invoice: $e')));
    }
  }

  Future<void> _finishTransaction(
    BuildContext context,
    CartService cart,
  ) async {
    try {
      // Save invoice first
      final invoice = Invoice(
        invoiceNumber: invoiceNumber,
        dateTime: DateTime.now(),
        products: List.from(cart.items),
        subtotal: cart.subtotal,
        totalCGST: cart.totalCGST,
        totalSGST: cart.totalSGST,
        totalAmount: cart.totalAmount,
      );

      await DatabaseHelper.instance.insertInvoice(invoice);

      // Clear the cart and return to home
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Transaction Complete'),
              content: const Text(
                'Invoice saved successfully. Start a new bill?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Provider.of<CartService>(
                      context,
                      listen: false,
                    ).clearCart();
                    Navigator.of(ctx).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save invoice: $e')));
    }
  }
}
