import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String token = "";
  DateTime? expiryDate;
  String userId = "";
  Timer? authTimer;

  bool get isAuth {
    return token != "";
  }

  String? get getToken {
    if (expiryDate != null &&
        expiryDate!.isAfter(DateTime.now()) &&
        token != "") {
      return token;
    }
    return null;
  }

  String? get getUserId {
    return userId;
  }

  Future<void> authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCYq2CzTPbCHruYqlSRGM5q9fre_3LALvY');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      token = responseData['idToken'];
      userId = responseData['localId'];
      expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': token,
          'userId': userId,
          'expireyDate': expiryDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String? email, String? password) async {
    return authenticate(email!, password!, 'signUp');
  }

  Future<void> login(String? email, String? password) async {
    return authenticate(email!, password!, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    late final userDataString;
    if (!prefs.containsKey('userData')) {
      return false;
    }
    if (prefs.getString('userData') != null) {
      userDataString = prefs.getString('userData');
    } else {
      return false;
    }
    final extractedUserData =
        json.decode(userDataString) as Map<String, Object>;
    var expiryDate = DateTime.parse(extractedUserData['expireyDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    token = extractedUserData['token'] as String;
    userId = extractedUserData['userId'] as String;
    expiryDate = expiryDate;
    notifyListeners();
    autoLogout();
    return true;
  }

  Future<void> logout() async {
    token = "";
    userId = "";
    expiryDate = null;
    if (authTimer != null) {
      authTimer!.cancel();
      authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    if (authTimer != null) {
      authTimer!.cancel();
    }
    final timeToExpiry = expiryDate!.difference(DateTime.now()).inSeconds;
    authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
