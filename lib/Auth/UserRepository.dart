import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status { Uninitialized, UserAuthenticated, Authenticating, Unauthenticated, AdminAuthenticated,
              LogIn, MemberSignUP, AdminSignUP, ChooseStatus, Welcome, JoinMoreOrganizations, CreateMoreOrganizations}

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  FirebaseUser _user;
  String _errorMessage;
  Status _status = Status.Uninitialized;

  UserRepository(): _auth = FirebaseAuth.instance {
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  Status get status => _status;
  FirebaseUser get user => _user;
  String get errorMessage => _errorMessage;

  set setErrorMessage(String error) => _errorMessage = error;


  Future<String> register(String email, String password) async {
    try{
      _status = Status.Authenticating;
      notifyListeners();
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    }catch(e){
      switch (e.code) {
      case "ERROR_OPERATION_NOT_ALLOWED":
        _errorMessage = "Anonymous accounts are not enabled";
        break;
      case "ERROR_WEAK_PASSWORD":
        _errorMessage = "The length of password should be longer than 6";
        break;
      case "ERROR_INVALID_EMAIL":
        _errorMessage = "Your email is invalid";
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        _errorMessage = "Email is already in use on different account";
        break;
      case "ERROR_INVALID_CREDENTIAL":
        _errorMessage = "Your email is invalid";
        break;
      default:
        _errorMessage = "An undefined Error happened.";
    }
      _status = Status.MemberSignUP;
      notifyListeners();
      return null;
    }
    return user.uid;
  }

  Future<String> registerManager(String email, String password) async {
    try{
      _status = Status.Authenticating;
      notifyListeners();
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    }catch(e){
      switch (e.code) {
      case "ERROR_OPERATION_NOT_ALLOWED":
        _errorMessage = "Anonymous accounts are not enabled";
        break;
      case "ERROR_WEAK_PASSWORD":
        _errorMessage = "The length of password should be longer than 6";
        break;
      case "ERROR_INVALID_EMAIL":
        _errorMessage = "Your email is invalid";
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        _errorMessage = "Email is already in use on different account";
        break;
      case "ERROR_INVALID_CREDENTIAL":
        _errorMessage = "Your email is invalid";
        break;
      default:
        _errorMessage = "An undefined Error happened.";
    }
      _status = Status.AdminSignUP;
      notifyListeners();
      return null;
    }
    return user.uid;
  }

  Future<String> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      switch (e.code) {
      case "ERROR_INVALID_EMAIL":
        _errorMessage = "Your email address appears to be malformed.";
        break;
      case "ERROR_WRONG_PASSWORD":
        _errorMessage = "Your password is wrong.";
        break;
      case "ERROR_USER_NOT_FOUND":
        _errorMessage = "User with this email doesn't exist.";
        break;
      case "ERROR_USER_DISABLED":
        _errorMessage = "User with this email has been disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        _errorMessage = "Too many requests. Try again later.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        _errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      default:
        _errorMessage = "An undefined Error happened.";
    }
      _status = Status.LogIn;
      notifyListeners(); 
      return null;
    }
    return user.uid;
  }

  void goToLogIn(){
    _status = Status.LogIn;
    notifyListeners();
  }

  void goToAdminSignUp(){
  _status = Status.AdminSignUP;
  notifyListeners();
  }

  void goToMemberSignUp(){
  _status = Status.MemberSignUP;
  notifyListeners();
  }

  void goToChooseStatus(){
  _status = Status.ChooseStatus;
  notifyListeners();
  }

  void goToWelcome(){
   _status = Status.Welcome;
   notifyListeners();
  }

  void goToJoin(){
   _status = Status.JoinMoreOrganizations;
   notifyListeners();
  }
  void gotoCreate(){
    _status = Status.CreateMoreOrganizations;
   notifyListeners();
  }
  void gotoUser(){
    _status = Status.UserAuthenticated;
   notifyListeners();
  }
  void gotoAdmin(){
    _status = Status.AdminAuthenticated;
   notifyListeners();
  }
  

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future tempSignOut() async {
    _auth.signOut();
    _status = Status.Uninitialized;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      String status = '';
      String organization;

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      organization = sharedPreferences.getString('organization');

      if (organization == null || organization.isEmpty)  {
        //_status = Status.Unauthenticated ;
        signOut();
      }else{

      await Firestore.instance.collection('users').document(organization).collection('users').document(_user.email).get().then((DocumentSnapshot ds) {
            status = ds['status'];
      });
      if (status == "admin") {
        _status = Status.AdminAuthenticated;
      } else{
        _status = Status.UserAuthenticated;

      }
      }
    }
    notifyListeners();
  }
}