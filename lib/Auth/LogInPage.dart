import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/Auth/ResetPasswordPage.dart';
import 'package:organizer/Auth/UserRepository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {

  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _email;
  String _password;
  var value;
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
      .then((_)=>_buildSnackBar()
      );
     super.initState();
   }
   
   _buildSnackBar (){
    final user = Provider.of<UserRepository>(context, listen: false);

    user.errorMessage == null ? print('') : 

     _scaffoldKey.currentState.showSnackBar(
       new SnackBar(
         content: new Text(user.errorMessage),
       )
     );
     user.setErrorMessage = null;
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
                SizedBox(height: size.height * 0.05,),
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    //onPressed: ()=> Navigator.pop(context),
                    onPressed: ()=> Provider.of<UserRepository>(context, listen: false).goToWelcome(),
                  ),
                ),
                Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 15),
                Image.asset('assets/logIn.png', height: size.height * 0.3,),
                SizedBox(height: 10),
                _showOrganizations(),
                _showEmailInput(),
                _showPasswordInput(),
                _showPrimaryButton(),
                _resetPassword(),
              ],
            ),
          ),
        ),
      )
    );
  }

Widget _showOrganizations(){
  Size size = MediaQuery.of(context).size;
  return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('organizations').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return Container(
              width: size.width * 0.8,
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: new DropdownButton<String>(
                isExpanded: true,
                hint: Text('Organization Name'),
                value: value,
                onChanged: (String newValue) {
                  setState(() {
                    value = newValue;
                  });
                },
                items: snapshot.data.documents.map((DocumentSnapshot document) {
                  return new DropdownMenuItem<String>(
                    value: document['name'],
                    child: new Text(document['name']),
                  );
                }).toList(),
              ),
            );
        }
      },
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
          icon: Icon(Icons.email) ,
          hintText: 'Enter Email',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none
        ),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
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
      side: BorderSide(color: Colors.lightBlue) 
),
        onPressed: () async {
          if(value != null){
          final user = Provider.of<UserRepository>(context, listen: false);
          if (_validateAndSave()) {
            SharedPreferences pref = await SharedPreferences.getInstance();
            await pref.setString('organization', value);

            final snapShot = await Firestore.instance.collection('users').document(value).collection('users').document(_email).get();

                if (snapShot == null ||!snapShot.exists){
                  user.setErrorMessage = 'You have not joined $value yet';
                  user.goToWelcome();
                }else{
              String id = await user.signIn(_email, _password);

              if(id != null){

              await pref.setString("id", id);

              Firestore.instance.collection('users').document(value).collection('users').document(_email).updateData({
                'password': _password,
              });
              DocumentReference documentReference =Firestore.instance.collection('users').document(value).collection('users').document(_email);
              documentReference.get().then((snapshot) async {
                if (snapshot.exists) {
                  await pref.setString('username', snapshot.data['username']);
                  await pref.setString('photoUrl', snapshot.data['photoUrl']);
                  await pref.setString('email', snapshot.data['email']);
                  await pref.setString('password', snapshot.data['password']);
                  await pref.setString('status', snapshot.data['status']);
                } 
              });
              }
            } 
            }  
        }else{
          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Please Choose a Organization')));
        }
        },
        child: new Text('LOGIN',style: new TextStyle(fontSize: 13.0, color: Colors.white))
      ),
    );
  }
  Widget _resetPassword() {
    return FlatButton(
        child: Text('Forget password?',
          style:new TextStyle(fontSize: 17.0, fontWeight: FontWeight.w300, color: Colors.grey)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPasswordPage()),
          );
        });
  }
}