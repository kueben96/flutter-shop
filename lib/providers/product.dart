import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

  void toggleFavStatus() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
