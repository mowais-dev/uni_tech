import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/screens/products/_partials/products_table.dart';
import 'package:flutter/material.dart';

class ProductsIndexScreen extends StatefulWidget {
  ProductsIndexScreen({super.key});

  @override
  State<ProductsIndexScreen> createState() => _ProductsIndexScreen();
}

class _ProductsIndexScreen extends State<ProductsIndexScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      content: Column(
        mainAxisSize: MainAxisSize.max,
        children: [ProductsTable(isIndexTable: true)],
      ),
    );
  }
}
