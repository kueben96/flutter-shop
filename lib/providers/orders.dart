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

  Future<void> addOrderHttp(List<CartItem> cartProducts, double total) async {
    final url =
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/orders";

    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'products': cartProducts,
          'dateTime': DateTime.now(),
        }));
    var res = json.decode(response.body);
    print(res);
    notifyListeners();
  }
}
