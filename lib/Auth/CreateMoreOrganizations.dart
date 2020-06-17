import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/Auth/UserRepository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateMoreOrganizations extends StatefulWidget {
  
  @override
  _CreateMoreOrganizationsState createState() => _CreateMoreOrganizationsState();
}

class _CreateMoreOrganizationsState extends State<CreateMoreOrganizations> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _organization; 
  String _email;
  String _status;
  String _password;
  String _username; 
  SharedPreferences prefs; 

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
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
    void initState() {
      new Future.delayed(const Duration(seconds: 1))
      .then((_)=>_buildSnackBar()
      );
      readLocal();
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

   void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    _status = prefs.getString('status') ?? '';
    _email = prefs.getString('email') ?? '';
    _password = prefs.getString('password') ?? '';
    _username = prefs.getString('username') ?? '';

    setState(() {});
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
                    onPressed: ()=> _status == 'admin' ? Provider.of<UserRepository>(context, listen: false).gotoAdmin() : 
                                                        Provider.of<UserRepository>(context, listen: false).gotoUser()
                  ),
                ),
                Text('Create Another Organization', style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 15),
                Image.asset('assets/signUp.png', height: size.height * 0.3,),
                SizedBox(height: 10),
                _showOrganizationInput(),
                _showPrimaryButton(),
              ],
            ),
          ),
        ),
      )
    );
  }
  Widget _showOrganizationInput() {
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
          icon: Icon(Icons.business) ,
          hintText: 'Enter Name of Organization',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none
        ),
        validator: (value) =>
          value.isEmpty ? 'Organization can\'t be empty' : null,
        onSaved: (value) => _organization = value,
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
          if (_validateAndSave()) {
           await _ifOrganizationExists(_organization).then((isTrue)async{
            if(!isTrue){ 
      
              final user = Provider.of<UserRepository>(context, listen: false);
              SharedPreferences pref = await SharedPreferences.getInstance();
              await pref.setString("organization", _organization);

              user.tempSignOut();

              String userId = "";

              userId = await user.signIn(_email, _password);
 
              if(userId != null){
                Firestore.instance.collection('organizations').document(_organization).setData({
                  'name' : _organization,
                  'managerId': userId, 
                  'email': _email,
                  'password': _password,
                }); 

                Firestore.instance.collection('users').document(_organization).collection('users').document(_email).setData({
                  'id': userId,
                  'email': _email,
                  'password': _password,
                  'username': _username,
                  'organization': _organization,
                  'status': 'admin',
                  'token':'waiting'
                });
                await pref.setString("id", userId);
                await pref.setString("username", _username);
                await pref.setString("email", _email);
                await pref.setString("photoUrl", '');
              }
                }else{
                  final snackbar =SnackBar(content: Text("Organization already exists!"));
                  _scaffoldKey.currentState.showSnackBar(snackbar);
                }
          });
            } 
            
        },
        child: new Text('Sign Up',style: new TextStyle(fontSize: 13.0, color: Colors.white))
      ),
    );
  } 
}