import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreRepository with ChangeNotifier{

  SharedPreferences preferences;
  String _username;

  String get username => _username;

  

  void chnageUsername()async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = await prefs.getString('username') ?? '';
    notifyListeners();

    notifyListeners();

  }




}