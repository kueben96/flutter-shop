import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// add changeNotifier so that Products can notify the listeners when they are changed (e.g. isFavorite == true)
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  // curly braces for named args, positional also possible without braces
  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  // ** for get request
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['name'],
      title: json['name']['title'],
      description: json['name']['description'],
      price: json['name']['price'],
      imageUrl: json['name']['imageUrl'],
      isFavorite: json['name']['isFavorite'],
    );
  }

  _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavStatus(String token) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/products/$id.json?auth=$token";
    try {
      final response = await http.patch(
        url,
        body: json.encode({
          'isFavorite': isFavorite,
        }),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
