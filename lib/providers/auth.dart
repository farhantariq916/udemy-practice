import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth with ChangeNotifier {
   late String _token='';
   late DateTime _expiryDate;
   late String _userId;


  bool get isAuth{
    // ignore: unnecessary_null_comparison
    return _token.isNotEmpty;
  }

  String get token{
    if(_expiryDate.toString().isNotEmpty && _expiryDate.isAfter(DateTime.now())&&_token.isNotEmpty){
      return _token;
    }
    return null.toString();
  }

  Future<void> _authenticate(String email,String password, String urlSegment) async{
    try{
      final url =
          'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDlwIyAwVTAQpvNTBUAXyGgCbdXO6ArQ_4';
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true},
        ),
      );
      final responseData = json.decode(response.body);
      if(responseData['error']!=null){
        throw Exception(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds:int.parse(responseData['expiresIn']) ),);
      notifyListeners();
    }

    catch(error){
      throw error;
    }



  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email,password,'signUp');

  }
  Future<void> login(String email, String password) async{
    return _authenticate(email, password, 'signInWithPassword');

  }
}
