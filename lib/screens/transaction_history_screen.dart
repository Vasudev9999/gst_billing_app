import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/invoice.dart';
import '../utils/gst_calculator.dart';
import 'invoice_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late Future<List<Invoice>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _refreshInvoices();
  }

  void _refreshInvoices() {
    setState(() {
      _invoicesFuture = DatabaseHelper.instance.getInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: FutureBuilder<List<Invoice>>(
        future: _invoicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          final invoices = snapshot.data!;
          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    'Invoice #${invoice.invoiceNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${invoice.formattedDate} | ${invoice.products.length} items',
                  ),
                  trailing: Text(
                    GstCalculator.formatCurrency(invoice.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => InvoiceDetailScreen(invoice: invoice),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
