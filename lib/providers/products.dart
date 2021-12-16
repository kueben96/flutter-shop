import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'product.dart';

// add Mixin like extend (but the difference is that you merge the properties but you dont turn your class of an instance of the inherited class)

class Products with ChangeNotifier {
  // _items shouldnt be accessible from outside (underscore makes private)
  List<Product> _items = [
    //   Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   ),
    //   Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    //   ),
    //   Product(
    //     id: 'p3',
    //     title: 'Yellow Scarf',
    //     description: 'Warm and cozy - exactly what you need for the winter.',
    //     price: 19.99,
    //     imageUrl:
    //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    //   ),
    //   Product(
    //     id: 'p4',
    //     title: 'A Pan',
    //     description: 'Prepare any meal you want.',
    //     price: 49.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    //   ),
  ];

  // Don't manage shwoing the favorites inside the class globally but locally inside the widgets
  // var _showFavoritesOnly = false;

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
    const url =
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/products.json";
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
          "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/products/$id.json";

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
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/products/$id.jon";
    // copy item before deleting
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];

    var exProd = existingProduct;
    //_items.removeAt(existingProductIndex);
    await http.delete(url).then((response) {
      print('items in request mode');
      _items.forEach((element) {
        print(element.title);
      });
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product');
      } else {
        existingProduct = null;
        _items.removeAt(existingProductIndex);
        print('***** items after successful delete');
        _items.forEach((element) {
          print(element.title);
        });
      }
      print('*** response status');
      print(response.statusCode);
    }).catchError((_) {
      //var existingProduct2 = existingProduct;
      //print(exProd.title);
      print('items in error mode');
      //_items.insert(existingProductIndex, exProd);
      _items.forEach((element) {
        print(element.title);
      });

      // re-insert into the list if removal fails
      print('Error occured');
    });
    //_items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }

  Future<void> fetchAndSetProducts() async {
    const url =
        "https://flutter-shop-app-94a3c-default-rtdb.firebaseio.com/products.json";
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
