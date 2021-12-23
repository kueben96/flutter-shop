import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/user_products_screen.dart';
import 'providers/products.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // group multiple providers together
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => Auth()),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders('', '', []),
            update: (ctx, auth, previousOrders) =>
                Orders(auth.token, auth.userId, previousOrders.orders),
          ),

          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products('', '', []),
            update: (ctx, auth, previousProducts) =>
                Products(auth.token, auth.userId, previousProducts.items),
          ),

          // ChangeNotifierProvider(
          //   // use .value constructor when you use existing objects like Product in existing List
          //   // but when you use objects that change like the Products List, use create and context
          //   create: (ctx) => Products(),
          // ),
        ],
        // all child widgets can now listen to the providers
        // build widget tree based on auth
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato'),
            home: auth.isAuth ? ProductOverviewScreen() : AuthScreen(),
            //home: AuthScreen(),
            routes: {
              ProducDetailScreen.routeName: (ctx) => ProducDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductsScreen.routeName: (context) => UserProductsScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          ),
        ));
  }
}
