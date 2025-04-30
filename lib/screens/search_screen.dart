import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../utils/gst_calculator.dart';
import 'invoice_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  List<Invoice> _filteredInvoices = [];
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _filteredProducts = [];
          _filteredInvoices = [];
        });
      } else {
        _performSearch(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    // Search products
    final products = await DatabaseHelper.instance.searchProducts(query);

    // Search invoices
    final invoices = await DatabaseHelper.instance.searchInvoices(query);

    setState(() {
      _filteredProducts = products;
      _filteredInvoices = invoices;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search products or invoices...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
              },
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Products'), Tab(text: 'Invoices')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Products tab
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isSearching && _filteredProducts.isEmpty
              ? const Center(child: Text('No products found'))
              : _buildProductsList(),

          // Invoices tab
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isSearching && _filteredInvoices.isEmpty
              ? const Center(child: Text('No invoices found'))
              : _buildInvoicesList(),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (!_isSearching) {
      return const Center(child: Text('Enter search term'));
    }

    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text(
              'GST: ${GstCalculator.formatPercentage(product.gstRate)}',
            ),
            trailing: Text(
              GstCalculator.formatCurrency(product.price),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoicesList() {
    if (!_isSearching) {
      return const Center(child: Text('Enter search term'));
    }

    return ListView.builder(
      itemCount: _filteredInvoices.length,
      itemBuilder: (context, index) {
        final invoice = _filteredInvoices[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text('Invoice #${invoice.invoiceNumber}'),
            subtitle: Text(
              '${invoice.formattedDate} | ${invoice.products.length} items',
            ),
            trailing: Text(
              GstCalculator.formatCurrency(invoice.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceDetailScreen(invoice: invoice),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
