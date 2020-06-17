import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/Services/FirestoreRepository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeUsername extends StatefulWidget {
  @override
  _ChangeUsernameState createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController usernameController = new TextEditingController();

  SharedPreferences prefs;

  String email;
  String username;
  String organization;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

   @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    email = prefs.getString('email') ?? '';
    organization = prefs.getString('organization') ?? '';

    usernameController = new TextEditingController(text: username);

    setState(() {});
  } 

  bool _validateAndSave() {
    final form = _formKey.currentState;
    
    if (form.validate()) {
      return true;
    }
    return false;
  } 


  void handleUpdateData() {
    final firestore = Provider.of<FirestoreRepository>(context, listen: false);

    Firestore.instance.collection('users').document(organization).collection('users').document(email).updateData({
      'username': username,
    }).then((data) async {
      await prefs.setString('username', username);

      setState(() {
        isLoading = false;
      });
      firestore.chnageUsername();
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text('Updated Successful'))); 
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Username'),),
      body: Align(
        alignment: Alignment.center,
        child: Form(
          key: _formKey,
          child: Stack(
            children:[
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
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      decoration: InputDecoration(
                        icon: Icon(Icons.portrait) ,
                        labelText: 'Enter Your Username',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none
                      ),
                      validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
                      controller: usernameController,
                      onChanged: (value) {
                        username = value;
                      },
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
                       child: new Text('Update',style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Colors.white)),
                       onPressed: (){

                         setState(() {
                             isLoading = true;
                           });

                        if (_validateAndSave()) 
                          handleUpdateData();
                       },
                     ),
                   )
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
        ),
      )
    );
  }
}