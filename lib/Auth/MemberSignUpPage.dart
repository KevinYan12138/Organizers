import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:organizer/Auth/UserRepository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberSignUpPage extends StatefulWidget {
  @override
  _MemberSignUpPageState createState() => _MemberSignUpPageState();
}

class _MemberSignUpPageState extends State<MemberSignUpPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _email; 
  String _password;  
  String _username;
  String _value;
  bool _agree = false;
  SharedPreferences prefs;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    new Future.delayed(const Duration(seconds: 1))
        .then((_) => _buildSnackBar());
    super.initState();
  }

  _buildSnackBar() {
    final user = Provider.of<UserRepository>(context, listen: false);

    user.errorMessage == null
        ? print('')
        : _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text(user.errorMessage),
          ));
    user.setErrorMessage = null;
  }

  static Future<bool> _ifOrganizationExists(String value) async{
    bool exist;
    await Firestore.instance.collection('organizations').document(value).get().then((doc) {
      if(doc.exists){
        exist = true;
      }else{
        exist = false;
      }
    });
    return exist;
    
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      //onPressed: ()=> Navigator.pop(context),
                      onPressed: () =>
                          Provider.of<UserRepository>(context, listen: false)
                              .goToChooseStatus(),
                    ),
                  ),
                  Text(
                    'MEMBER SIGNUP',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Image.asset(
                    'assets/signUp.png',
                    height: size.height * 0.3,
                  ),
                  SizedBox(height: 10),
                  _showOrganizations(),
                  _showUsernameInput(),
                  _showEmailInput(),
                  _showPasswordInput(),
                  _showTerms(),
                  _showPrimaryButton(),
                ],
              ),
            ),
          ),
        ));
  }

  // Widget _showOrganizations() {
  //   Size size = MediaQuery.of(context).size;
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: Firestore.instance.collection('organizations').snapshots(),
  //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //       if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
  //       switch (snapshot.connectionState) {
  //         case ConnectionState.waiting:
  //           return new Text('Loading...');
  //         default:
  //           return Container(
  //             width: size.width * 0.8,
  //             margin: EdgeInsets.symmetric(vertical: 10),
  //             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
  //             decoration: BoxDecoration(
  //               color: Colors.lightBlue[100],
  //               borderRadius: BorderRadius.circular(30),
  //             ),
  //             child: new DropdownButton<String>(
  //               isExpanded: true,
  //               hint: Text('Organization Name'),
  //               value: value,
  //               onChanged: (String newValue) {
  //                 setState(() {
  //                   value = newValue;
  //                 });
  //               },
  //               items: snapshot.data.documents.map((DocumentSnapshot document) {
  //                 return new DropdownMenuItem<String>(
  //                   value: document['name'],
  //                   child: new Text(document['name']),
  //                 );
  //               }).toList(),
  //             ),
  //           );
  //       }
  //     },
  //   );
  // }

  Widget _showOrganizations() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          icon: Icon(Icons.email) ,
          hintText: 'Enter Organization Name',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none
        ),
        validator: (value) => value.isEmpty ? 'Organization can\'t be empty' : null,
        onSaved: (value) => _value = value,
      ),
    );
  }

  Widget _showEmailInput() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            icon: Icon(Icons.email),
            hintText: 'Enter Email',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showUsernameInput() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            icon: Icon(Icons.person),
            hintText: 'Enter Username',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none),
        validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
        onSaved: (value) => _username = value,
      ),
    );
  }

  Widget _showPasswordInput() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          icon: Icon(Icons.lock),
          border: InputBorder.none,
          hintText: 'Enter Password',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showTerms() {
    Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        Checkbox(
          value: _agree,
          onChanged: (bool newValue){
            setState(() {
              _agree = newValue;
            });
          },
        ),
        Container(
          width: size.width * 0.8,
          child: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 12),
            children: <TextSpan>[
              TextSpan(
                text: "I agree to Organizers's ",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              TextSpan(
                text: "Terms and Conditions",
                recognizer: TapGestureRecognizer()
                ..onTap = (){
                  launch('https://guanwenyan.com/#/Organizers/Terms');
                },
                style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline),
              ),
              TextSpan(
                text: " and ",
                style: TextStyle(color: Colors.black, fontSize: 12,),
              ),
              TextSpan(
                text: "Privacy Policy",
                recognizer: TapGestureRecognizer()
                ..onTap = (){
                  launch("https://guanwenyan.com/#/Organizers/Privacy");
                },
                style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline),
              ),
            ],
          ),
      ),
        ),
      ],
    );
  }

  Widget _showPrimaryButton() {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.06,
      width: size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: RaisedButton(
          color: Colors.lightBlue,
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(50.0),
              side: BorderSide(color: Colors.lightBlue)),
          onPressed: () async {
            if(_agree){
            if (_validateAndSave()) {
              await _ifOrganizationExists(_value).then((isTrue)async{
              if(isTrue == true){
              final user = Provider.of<UserRepository>(context, listen: false);
              SharedPreferences pref = await SharedPreferences.getInstance();

              String userId = "";
              await pref.setString("organization", _value);

              userId = await user.register(_email, _password);

              if (userId != null) {
                Firestore.instance
                    .collection('users')
                    .document(_value)
                    .collection('users')
                    .document(_email)
                    .setData({
                  'id': userId,
                  'email': _email,
                  'password': _password,
                  'username': _username,
                  'organization': _value,
                  'status': 'member',
                  'token': 'waiting'
                });
                await pref.setString("id", userId);
                await pref.setString("email", _email);
                await pref.setString("password", _password);
                await pref.setString("status", 'member');
                await pref.setString("username", _username);
                await pref.setString("photoUrl", '');
              }
            }else{
              _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Organization doesn\'t exist')));
            }
            });
            }
          }else{
            _showMyDialog();
          }
          },
          child: new Text('Sign Up',
              style: new TextStyle(fontSize: 13.0, color: Colors.white))),
    );
  }
  Future<void> _showMyDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text('Oops!')),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('You must accept the Terms and Conditions and Privacy Policy.'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
}
