import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import './product_item.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    // to which type of data shall the provider listen? <Products>
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favItems : productsData.items;
    print('Show favs');
    print(showFavs);
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      // structure of grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      // set up a provider for single product
      itemBuilder: (BuildContext context, int index) =>
          ChangeNotifierProvider.value(
              value: products[index], child: ProductItem()),
    );
  }
}
