import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/gst_calculator.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GST Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: ElevatedButton(
                      onPressed: _calculateGST,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Text('Calculate GST'),
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
              _buildCalculationRow(
                'Price',
                GstCalculator.formatCurrency(_currentProduct!.price),
              ),
              _buildCalculationRow(
                'GST Rate',
                GstCalculator.formatPercentage(_currentProduct!.gstRate),
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
                GstCalculator.formatCurrency(_currentProduct!.totalPrice),
                isTotal: true,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // To be implemented in Version 3 - Add to cart functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Add to cart functionality coming in Version 3!',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('Add to Bill'),
                  ),
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
