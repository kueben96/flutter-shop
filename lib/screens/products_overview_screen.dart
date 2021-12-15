import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

// Grid of Products

enum FilterOptions { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  @override
  void initState() {
    //Provider.of<Products>(context).fetchAndSetProducts(); WON'T WORK
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    // });
    super.initState();
  }

  // runs after init but before build of widgets
  // only run if inits initial and set false later so it newer runs again
  @override
  void didChangeDependencies() {
    Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold for the whole screen incl. AppBar

    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
                print(_showOnlyFavorites);
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show all'),
                value: FilterOptions.All,
              )
            ],
            icon: Icon(
              Icons.more_vert,
            ),
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch!,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_basket),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: ProductsGrid(_showOnlyFavorites),
    );
  }
}
