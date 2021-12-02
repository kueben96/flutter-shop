import 'package:flutter/material.dart';
import 'package:shop_app/widgets/products_grid.dart';

// Grid of Products

class ProductOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold for the whole screen incl. AppBar
    return Scaffold(
      appBar: AppBar(
        title: Text('My2 Shop'),
      ),
      body: ProductsGrid(),
    );
  }
}
