import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  late String _token;
  late DateTime _expiryDate = DateTime.now();
  late String _userId;
  Timer? _authTimer;

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
      _autoLogout();
      notifyListeners();

      // set up shared preferences to store info on the device with key values
      // you can store maps like json.encode({''})
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);

      // print('test print');
      // print(responseData['expiresIn']);
      // print(DateTime.now());
      // print(_expiryDate);
      // // responseData.forEach((key, value) {
      //   print(key);
      //   print(value);
      // });

      //_token = response;
      print(responseData);
    } catch (error) {
      throw error;
    }
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

  // method to retrieve userData

  Future<bool> tryAutoLogin() async {
    print('*** trying auto login');
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      print('returns false');
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    print("Extracted User Data $extractedUserData");
    final expiryDate = extractedUserData['expiryDate'];

    var expiryDateTest = DateTime.parse(expiryDate.toString());

    if (expiryDateTest.isBefore(DateTime.now())) {
      print('returns false');
      return false;
    }

    _token = extractedUserData['token'].toString();
    print('** _TOKEN $_token');
    _userId = extractedUserData['userId'].toString();
    _expiryDate = DateTime.parse(extractedUserData['expiryDate'].toString());
    print('** _expiryDate $_expiryDate');
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = "";
    _userId = "";
    _expiryDate = DateTime.now();
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
