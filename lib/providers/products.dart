import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth.dart';
import 'product.dart';

// add Mixin like extend (but the difference is that you merge the properties but you dont turn your class of an instance of the inherited class)

class Products with ChangeNotifier {
  // _items shouldnt be accessible from outside (underscore makes private)
  List<Product> _items = [];

  // Don't manage shwoing the favorites inside the class globally but locally inside the widgets
  // var _showFavoritesOnly = false;

  final String authToken;

  Products(this.authToken, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }

    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  // put most of the logic to provider

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    // async automatically returns future so you dont need .then()
    final url =
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/products.json?auth=$authToken";
    // returns a future which can be accessed from outside of the class
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite
        }),
      );
      var res = json.decode(response.body);

      final newProduct = Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: res['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      // throw new error to use it in other place
      throw error;
    }
    // when future succeeds -> run then
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";

      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      // update in local memory
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    print('delete prod invoked');
    final url =
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
    // copy item before deleting
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    var exProd = existingProduct;

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      // makes more sense to me
      //_items.insert(existingProductIndex, existingProduct);

      throw HttpException('Could not delete product');
    }
    existingProduct = null;
    _items.removeAt(existingProductIndex);
    notifyListeners();
  }

  Future<void> fetchAndSetProducts() async {
    final url =
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/products.json?auth=$authToken";
    try {
      final response = await http.get(url);
      final productData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      // for each (key, value)
      productData.forEach((productId, productData) {
        loadedProducts.add(Product(
            id: productId,
            title: productData['title'],
            price: productData['price'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            isFavorite: productData['isFavorite']));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
