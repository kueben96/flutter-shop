import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  late String _token;
  late DateTime _expiryDate = DateTime.now();
  late String _userId;

  bool get isAuth {
    return token != "";
  }

  String get token {
    if (_expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return "";
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB9N4Z66yv4SnwRoMgmjAGJsOwjZD1lbYo";

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true},
        ),
      );
      // check response data
      var responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      responseData = responseData as Map<String, dynamic>;
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      print('test print');
      print(responseData['expiresIn']);
      print(DateTime.now());
      print(_expiryDate);
      // responseData.forEach((key, value) {
      //   print(key);
      //   print(value);
      // });

      //_token = response;
      print(responseData);
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  Future<void> signup(
    String email,
    String password,
  ) async {
    var urlSegment = "signUp";
    return _authenticate(email, password, urlSegment);
  }

  Future<void> signIn(String email, String password) async {
    var urlSegment = "signInWithPassword";
    return _authenticate(email, password, urlSegment);
  }

  void logout() {
    _token = "";
    _userId = "";
    _expiryDate = DateTime.now();
    notifyListeners();
  }
}
