import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/invoice.dart';
import '../utils/gst_calculator.dart';
import '../widgets/search_bar.dart';
import 'invoice_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late Future<List<Invoice>> _invoicesFuture;
  List<Invoice> _filteredInvoices = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _refreshInvoices();
    _searchController.addListener(() {
      _filterInvoices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshInvoices() {
    setState(() {
      _invoicesFuture = DatabaseHelper.instance.getInvoices();
      _invoicesFuture.then((invoices) {
        _filteredInvoices = invoices;
      });
    });
  }

  void _filterInvoices() {
    if (_searchController.text.isEmpty &&
        _startDate == null &&
        _endDate == null) {
      setState(() {
        _isSearching = false;
      });
      _refreshInvoices();
      return;
    }

    _invoicesFuture.then((invoices) {
      List<Invoice> filtered = List.from(invoices);

      // Filter by search text
      if (_searchController.text.isNotEmpty) {
        filtered =
            filtered
                .where(
                  (invoice) => invoice.invoiceNumber.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
                )
                .toList();
      }

      // Filter by date range
      if (_startDate != null) {
        filtered =
            filtered
                .where(
                  (invoice) =>
                      invoice.dateTime.isAfter(_startDate!) ||
                      invoice.dateTime.isAtSameMomentAs(_startDate!),
                )
                .toList();
      }

      if (_endDate != null) {
        DateTime endOfDay = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
        );
        filtered =
            filtered
                .where(
                  (invoice) =>
                      invoice.dateTime.isBefore(endOfDay) ||
                      invoice.dateTime.isAtSameMomentAs(endOfDay),
                )
                .toList();
      }

      setState(() {
        _filteredInvoices = filtered;
        _isSearching = true;
      });
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _endDate ?? DateTime.now(),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
      });
      _filterInvoices();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
      _isSearching = false;
    });
    _refreshInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CustomSearchBar(
            controller: _searchController,
            hintText: 'Search by invoice number...',
            onClear: () {
              _searchController.clear();
              _filterInvoices();
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // Date filter indicator
          if (_startDate != null || _endDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getDateRangeText(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _clearFilters,
                  ),
                ],
              ),
            ),

          // Invoices list
          Expanded(
            child: FutureBuilder<List<Invoice>>(
              future: _invoicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No transactions found'));
                }

                final invoices =
                    _isSearching ? _filteredInvoices : snapshot.data!;

                if (invoices.isEmpty) {
                  return const Center(
                    child: Text('No matching invoices found'),
                  );
                }

                return ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                                  (context) =>
                                      InvoiceDetailScreen(invoice: invoice),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Summary section at the bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<int>(
                  future: DatabaseHelper.instance.getInvoiceCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Text('Total Invoices: $count');
                  },
                ),
                FutureBuilder<double>(
                  future: DatabaseHelper.instance.getTotalRevenue(),
                  builder: (context, snapshot) {
                    final total = snapshot.data ?? 0.0;
                    return Text(
                      'Total: ${GstCalculator.formatCurrency(total)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return 'Date Range: ${_dateFormat.format(_startDate!)} - ${_dateFormat.format(_endDate!)}';
    } else if (_startDate != null) {
      return 'From: ${_dateFormat.format(_startDate!)}';
    } else if (_endDate != null) {
      return 'Until: ${_dateFormat.format(_endDate!)}';
    }
    return '';
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Date Range'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _selectDateRange(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: const Text('Sort by Amount (High to Low)'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sortInvoices(true);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: const Text('Sort by Amount (Low to High)'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sortInvoices(false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Clear Filters'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _clearFilters();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _sortInvoices(bool descending) {
    _invoicesFuture.then((invoices) {
      List<Invoice> sorted = List.from(invoices);
      if (descending) {
        sorted.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      } else {
        sorted.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
      }

      setState(() {
        _filteredInvoices = sorted;
        _isSearching = true;
      });
    });
  }
}
