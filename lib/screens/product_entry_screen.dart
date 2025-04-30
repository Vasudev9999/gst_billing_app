import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // In Version 1, just show a message
                      // Actual calculation will be implemented in Version 2
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Product added (calculation coming in Version 2)',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('Add Product'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
