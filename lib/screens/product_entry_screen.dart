import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../utils/gst_calculator.dart';
import '../database/database_helper.dart';
import 'cart_screen.dart';

class ProductEntryScreen extends StatefulWidget {
  const ProductEntryScreen({Key? key}) : super(key: key);

  @override
  _ProductEntryScreenState createState() => _ProductEntryScreenState();
}

class _ProductEntryScreenState extends State<ProductEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  double _selectedGstRate = 0.18; // Default to 18%

  final List<double> _gstRates = [0.05, 0.12, 0.18, 0.28]; // 5%, 12%, 18%, 28%

  // For displaying calculation results
  Product? _currentProduct;
  bool _showCalculation = false;

  // For search and recent products
  List<Product> _recentProducts = [];
  bool _isSearching = false;
  List<Product> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentProducts();
  }

  Future<void> _loadRecentProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await DatabaseHelper.instance.getProducts();
      setState(() {
        _recentProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _calculateGST() {
    if (_formKey.currentState!.validate()) {
      final productName = _productNameController.text;
      final price = double.parse(_priceController.text);

      setState(() {
        _currentProduct = Product(
          name: productName,
          price: price,
          gstRate: _selectedGstRate,
        );
        _showCalculation = true;
      });
    }
  }

  void _addToCart() {
    if (_currentProduct != null) {
      // Add to cart using Provider
      Provider.of<CartService>(
        context,
        listen: false,
      ).addProduct(_currentProduct!);

      // Save to product database for future use
      _saveProduct(_currentProduct!);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_currentProduct!.name} added to bill'),
          action: SnackBarAction(
            label: 'VIEW BILL',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ),
      );

      // Reset form
      setState(() {
        _showCalculation = false;
        _productNameController.clear();
        _priceController.clear();
        _currentProduct = null;
      });

      // Reload products list
      _loadRecentProducts();
    }
  }

  Future<void> _saveProduct(Product product) async {
    try {
      // Don't save if a similar product already exists
      bool exists = _recentProducts.any(
        (p) =>
            p.name.toLowerCase() == product.name.toLowerCase() &&
            p.price == product.price &&
            p.gstRate == product.gstRate,
      );

      if (!exists) {
        await DatabaseHelper.instance.insertProduct(product);
      }
    } catch (e) {
      // Silent error - no need to show to user
      debugPrint('Error saving product: $e');
    }
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    final results =
        _recentProducts
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    setState(() {
      _isSearching = true;
      _searchResults = results;
    });
  }

  void _selectProduct(Product product) {
    setState(() {
      _productNameController.text = product.name;
      _priceController.text = product.price.toString();
      _selectedGstRate = product.gstRate;
      _isSearching = false;
      _searchResults = [];

      // Automatically calculate GST for selected product
      _currentProduct = product;
      _showCalculation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount = Provider.of<CartService>(context).items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product to Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ProductSearchDelegate(_recentProducts, (product) {
                  _selectProduct(product);
                }),
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Search TextField
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for a product',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _searchProducts,
            ),

            // Search Results
            if (_isSearching && _searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        '${GstCalculator.formatCurrency(product.price)} • GST: ${GstCalculator.formatPercentage(product.gstRate)}',
                      ),
                      onTap: () => _selectProduct(product),
                    );
                  },
                ),
              )
            else if (_isSearching && _searchResults.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('No products found')),
              ),

            const SizedBox(height: 20),

            // Product Entry Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<double>(
                    decoration: const InputDecoration(
                      labelText: 'GST Rate',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                    ),
                    value: _selectedGstRate,
                    items:
                        _gstRates.map((rate) {
                          return DropdownMenuItem<double>(
                            value: rate,
                            child: Text('${(rate * 100).toInt()}%'),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGstRate = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _calculateGST,
                      icon: const Icon(Icons.calculate),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text('Calculate GST'),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // GST Calculation Results
            if (_showCalculation && _currentProduct != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'GST Calculation for ${_currentProduct!.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildCalculationRow(
                        'Price',
                        GstCalculator.formatCurrency(_currentProduct!.price),
                      ),
                      _buildCalculationRow(
                        'GST Rate',
                        GstCalculator.formatPercentage(
                          _currentProduct!.gstRate,
                        ),
                      ),
                      _buildCalculationRow(
                        'CGST (${GstCalculator.formatPercentage(_currentProduct!.gstRate / 2)})',
                        GstCalculator.formatCurrency(_currentProduct!.cgst),
                      ),
                      _buildCalculationRow(
                        'SGST (${GstCalculator.formatPercentage(_currentProduct!.gstRate / 2)})',
                        GstCalculator.formatCurrency(_currentProduct!.sgst),
                      ),
                      const Divider(),
                      _buildCalculationRow(
                        'Total Price',
                        GstCalculator.formatCurrency(
                          _currentProduct!.totalPrice,
                        ),
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text('Add to Bill'),
                  ),
                ),
              ),
            ],

            // Recent Products
            if (!_isLoading &&
                _recentProducts.isNotEmpty &&
                !_showCalculation) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Recent Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  itemCount:
                      _recentProducts.length > 10 ? 10 : _recentProducts.length,
                  itemBuilder: (context, index) {
                    final product = _recentProducts[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        '${GstCalculator.formatCurrency(product.price)} • GST: ${GstCalculator.formatPercentage(product.gstRate)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _selectProduct(product),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
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

// Custom search delegate for products
class _ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;
  final Function(Product) onSelect;

  _ProductSearchDelegate(this.products, this.onSelect);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Type to search for products'));
    }

    final results =
        products
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    if (results.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text(
            '${GstCalculator.formatCurrency(product.price)} • GST: ${GstCalculator.formatPercentage(product.gstRate)}',
          ),
          onTap: () {
            onSelect(product);
            close(context, product);
          },
        );
      },
    );
  }
}
