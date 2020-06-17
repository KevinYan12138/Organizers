import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  String _email;
  String _errorMessage;
  bool isLoading = false;
  
  FirebaseAuth auth = FirebaseAuth.instance;
  
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<String> resetPassword(String email) async {
    try{
     await auth.sendPasswordResetEmail(email: email);
     return "Check your email to reset password";
    } catch(e){
      switch (e.code) {
        case 'ERROR_INVALID_EMAIL' :
        return 'the email address is malformed';
        break;
        case 'ERROR_USER_NOT_FOUND' :
        return 'there is no user corresponding to the given email address';
        break;  
        default:
        return "An undefined Error happened.";
      }
    }
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  } 

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Reset Password'),
          backgroundColor: Colors.lightBlue,
        ),
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
             Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: size.height * 0.05,),
                   Container(
                    width: size.width * 0.8,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                      color: Colors.grey,
                    ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email) ,
                        labelText: 'Enter Your Email',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none
                      ),
                      validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
                      onSaved: (value) => _email = value,
                    ),
                  ),
                   Container(
                     width: size.width * 0.8,
                     child: RaisedButton(
                       color: Colors.lightBlue,
                       shape: RoundedRectangleBorder(
                           borderRadius: new BorderRadius.circular(50.0),
                           side: BorderSide(color: Colors.lightBlue)
                       ),
                       child: new Text('Sumbit',style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Colors.white)),
                       onPressed: () async{
                         setState(() {
                           isLoading = true;
                         });

                         if (_validateAndSave()) {
                           _errorMessage = await resetPassword(_email);

                           setState(() {
                           isLoading = false;
                         });

                           _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(_errorMessage)));
                        
                         }
                       },
                     ),
                   ),
                ],
              ),
            ),
            isLoading ? Center(
                   child: Container(
                    width: size.width * 0.3,
                    height: size.width * 0.3,
                    child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightBlue),)
              ),
                 ): Container()
            ]
          ),
        )
        );
  }
}
