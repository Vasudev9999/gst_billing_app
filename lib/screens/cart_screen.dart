import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../utils/gst_calculator.dart';
import 'invoice_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _confirmClearCart(context);
            },
          ),
        ],
      ),
      body: Consumer<CartService>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Text(
                'No products added yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final product = cart.items[index];
                    return _buildCartItem(context, product, index);
                  },
                ),
              ),
              _buildCartSummary(cart),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<CartService>(
        builder: (context, cart, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed:
                  cart.items.isEmpty
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceScreen(),
                          ),
                        );
                      },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'GENERATE INVOICE',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Product product, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(product.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: ${GstCalculator.formatCurrency(product.price)}'),
              Text('GST: ${GstCalculator.formatPercentage(product.gstRate)}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                GstCalculator.formatCurrency(product.totalPrice),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Provider.of<CartService>(
                    context,
                    listen: false,
                  ).removeProduct(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary(CartService cart) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(
            'Subtotal',
            GstCalculator.formatCurrency(cart.subtotal),
          ),
          _buildSummaryRow(
            'CGST',
            GstCalculator.formatCurrency(cart.totalCGST),
          ),
          _buildSummaryRow(
            'SGST',
            GstCalculator.formatCurrency(cart.totalSGST),
          ),
          const Divider(),
          _buildSummaryRow(
            'Total',
            GstCalculator.formatCurrency(cart.totalAmount),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Clear Cart'),
            content: const Text('Are you sure you want to remove all items?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<CartService>(context, listen: false).clearCart();
                  Navigator.of(ctx).pop();
                },
                child: const Text('CLEAR'),
              ),
            ],
          ),
    );
  }
}
