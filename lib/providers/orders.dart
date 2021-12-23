import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;

  Orders(this.authToken, this._orders);

  // to prevent editing orders from outside the class
  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/orders.json?auth=$authToken";
    final response = await http.get(url);
    print(json.decode(response.body));
    // helper list
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price']))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime'])));
    });
    //place new orders first
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrderHttp(List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();

    final url =
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/orders.json?auth=$authToken";

    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'price': cp.price,
                    'quantity': cp.quantity,
                  })
              .toList(),
          'dateTime': timestamp.toIso8601String(),
        }));
    var res = json.decode(response.body);
    print(res);
    _orders.insert(
      0,
      OrderItem(
        id: res['name'],
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    _orders.forEach((element) {
      print(element.toString());
    });
    notifyListeners();
  }
}
