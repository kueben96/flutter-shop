import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  late String _token;
  late DateTime _expiryDate;
  late String _userId;

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB9N4Z66yv4SnwRoMgmjAGJsOwjZD1lbYo";
    final response = await http.post(
      url,
      body: json.encode(
        {'email': email, 'password': password, 'returnSecureToken': true},
      ),
    );
    var responseData = json.decode(response.body);
    //_token = response;
    print(responseData);
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
}
