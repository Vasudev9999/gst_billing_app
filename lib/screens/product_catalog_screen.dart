import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/gst_calculator.dart';
import '../widgets/search_bar.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({Key? key}) : super(key: key);

  @override
  _ProductCatalogScreenState createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  late Future<List<Product>> _productsFuture;
  List<Product> _filteredProducts = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshProducts();
    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = DatabaseHelper.instance.getProducts();
      _productsFuture.then((products) {
        _filteredProducts = products;
      });
    });
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      _refreshProducts();
      return;
    }

    _productsFuture.then((products) {
      final filtered =
          products
              .where(
                (product) =>
                    product.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
      setState(() {
        _filteredProducts = filtered;
        _isSearching = true;
      });
    });
  }

  void _showAddProductDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _priceController = TextEditingController();
    double _selectedGstRate = 0.18;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add New Product'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price (₹)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<double>(
                      decoration: const InputDecoration(labelText: 'GST Rate'),
                      value: _selectedGstRate,
                      items:
                          [0.05, 0.12, 0.18, 0.28].map((rate) {
                            return DropdownMenuItem<double>(
                              value: rate,
                              child: Text('${(rate * 100).toInt()}%'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        _selectedGstRate = value!;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final product = Product(
                      name: _nameController.text,
                      price: double.parse(_priceController.text),
                      gstRate: _selectedGstRate,
                    );
                    DatabaseHelper.instance.insertProduct(product).then((_) {
                      _refreshProducts();
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product added successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  }
                },
                child: const Text('SAVE'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CustomSearchBar(
            controller: _searchController,
            hintText: 'Search products...',
            onClear: () {
              _searchController.clear();
              _filterProducts('');
            },
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found. Add some!'));
          }

          final products = _isSearching ? _filteredProducts : snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'GST: ${GstCalculator.formatPercentage(product.gstRate)}',
                  ),
                  trailing: Text(
                    GstCalculator.formatCurrency(product.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Show product details or edit option
                    _showProductOptions(product);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProductOptions(Product product) {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.shopping_cart_checkout),
                title: const Text('Add to Bill'),
                onTap: () {
                  Navigator.pop(context, product);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Product'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditProductDialog(product);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Product'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteProduct(product);
                },
              ),
            ],
          ),
    ).then((selectedProduct) {
      if (selectedProduct != null && selectedProduct is Product) {
        Navigator.pop(context, selectedProduct);
      }
    });
  }

  void _showEditProductDialog(Product product) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: product.name);
    final _priceController = TextEditingController(
      text: product.price.toString(),
    );
    double _selectedGstRate = product.gstRate;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Product'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price (₹)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<double>(
                      decoration: const InputDecoration(labelText: 'GST Rate'),
                      value: _selectedGstRate,
                      items:
                          [0.05, 0.12, 0.18, 0.28].map((rate) {
                            return DropdownMenuItem<double>(
                              value: rate,
                              child: Text('${(rate * 100).toInt()}%'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        _selectedGstRate = value!;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedProduct = Product(
                      id: product.id,
                      name: _nameController.text,
                      price: double.parse(_priceController.text),
                      gstRate: _selectedGstRate,
                    );
                    DatabaseHelper.instance.updateProduct(updatedProduct).then((
                      _,
                    ) {
                      _refreshProducts();
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product updated successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  }
                },
                child: const Text('UPDATE'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Product'),
            content: Text('Are you sure you want to delete "${product.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  DatabaseHelper.instance.deleteProduct(product.id!).then((_) {
                    _refreshProducts();
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product deleted successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                },
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }
}
