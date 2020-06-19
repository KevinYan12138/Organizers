import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/Auth/UserRepository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JoinMoreOrganizations extends StatefulWidget {
  @override
  _JoinMoreOrganizationsState createState() => _JoinMoreOrganizationsState();
}

class _JoinMoreOrganizationsState extends State<JoinMoreOrganizations> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _email; 
  String _status;
  String _password;
  String _username;  
  String _value;
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
                Text('Join Another Organization', style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 15),
                Image.asset('assets/signUp.png', height: size.height * 0.3,),
                SizedBox(height: 10),
                _showOrganizations(),
                _showPrimaryButton(),
              ],
            ),
          ),
        ),
      )
    );
  }

  // Widget _showOrganizations(){
  // Size size = MediaQuery.of(context).size;
  // return StreamBuilder<QuerySnapshot>(
  //     stream: Firestore.instance.collection('organizations').snapshots(),
  //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //       if (snapshot.hasError)return new Text('Error: ${snapshot.error}');
  //       switch (snapshot.connectionState) {
  //         case ConnectionState.waiting: return new Text('Loading...');
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
          icon: Icon(Icons.business) ,
          hintText: 'Organization Name',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none
        ),
        validator: (value) => value.isEmpty ? 'Organization can\'t be empty' : null,
        onSaved: (value) => _value = value,
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
            await _ifOrganizationExists(_value).then((isTrue)async{
              if(isTrue == true){
              final user = Provider.of<UserRepository>(context, listen: false);
              SharedPreferences pref = await SharedPreferences.getInstance();

              await pref.setString("organization", _value);

              final snapShot = await Firestore.instance.collection('users').document(_value).collection('users').document(_email).get();

                if (snapShot.exists){
                  _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('You have already joined $_value')));
                }else{
              
              String userId = "";
              user.tempSignOut();
              userId = await user.signIn(_email, _password);

              if(userId != null){
              Firestore.instance.collection('users').document(_value).collection('users').document(_email).setData({
                  'id': userId,
                  'email': _email,
                  'password': _password,
                  'username': _username,
                  'organization': _value,
                  'status': 'member',
                  'token':'waiting'
                });
                await pref.setString("id", userId);
                await pref.setString("username", _username);
                await pref.setString("photoUrl", '');
            } 
          }
              }else{
              _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Organization doesn\'t exist')));
            }
            });
          }
        },
        child: new Text('Join',style: new TextStyle(fontSize: 15.0, color: Colors.white))
      ),
    );
  } 
}
