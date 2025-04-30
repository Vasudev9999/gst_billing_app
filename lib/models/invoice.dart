import 'dart:convert';
import 'package:intl/intl.dart';
import 'product.dart';

class Invoice {
  final int? id;
  final String invoiceNumber;
  final DateTime dateTime;
  final List<Product> products;
  final double subtotal;
  final double totalCGST;
  final double totalSGST;
  final double totalAmount;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.dateTime,
    required this.products,
    required this.subtotal,
    required this.totalCGST,
    required this.totalSGST,
    required this.totalAmount,
  });

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  String get formattedTime {
    return DateFormat('HH:mm').format(dateTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'dateTime': dateTime.toIso8601String(),
      'products': jsonEncode(
        products.map((product) => product.toMap()).toList(),
      ),
      'subtotal': subtotal,
      'totalCGST': totalCGST,
      'totalSGST': totalSGST,
      'totalAmount': totalAmount,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    List<dynamic> productsJson = jsonDecode(map['products']);
    List<Product> products =
        productsJson
            .map(
              (productJson) =>
                  Product.fromMap(Map<String, dynamic>.from(productJson)),
            )
            .toList();

    return Invoice(
      id: map['id'],
      invoiceNumber: map['invoiceNumber'],
      dateTime: DateTime.parse(map['dateTime']),
      products: products,
      subtotal: map['subtotal'],
      totalCGST: map['totalCGST'],
      totalSGST: map['totalSGST'],
      totalAmount: map['totalAmount'],
    );
  }
}
