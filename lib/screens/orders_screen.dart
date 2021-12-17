import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                // error handling
                return Center(
                  child: Text('Error occured'),
                );
              } else {
                // no error
                // fetch data with consumer because provider would cause rebuilding the whole widget tree and end up in an infinite loop
                return Consumer<Orders>(
                    builder: (context, orderData, child) => ListView.builder(
                          itemBuilder: (context, index) =>
                              OrderItem(orderData.orders[index]),
                          itemCount: orderData.orders.length,
                        ));
              }
            }
          },
        ));
  }
}
