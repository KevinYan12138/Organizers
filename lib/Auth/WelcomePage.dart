import 'dart:io';

import 'package:flutter/material.dart';
import 'package:organizer/Auth/UserRepository.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
   GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

// @override
//   void didChangeDependencies() {

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

//       final user = Provider.of<UserRepository>(context);
      
//       if(user.status == Status.Uninitialized){
//         Navigator.pushReplacementNamed(context, '/Splash');
//       }else if(user.status == Status.Authenticating){
//         Navigator.pushReplacementNamed(context, '/Splash');
//       }else if(user.status == Status.Unauthenticated){
//         Navigator.pushReplacementNamed(context, '/WelcomePage');
//       }else if(user.status == Status.UserAuthenticated){
//         Navigator.pushReplacementNamed(context, '/BottomNavigation');
//       }else if(user.status == Status.AdminAuthenticated){
//         Navigator.pushReplacementNamed(context, '/ManagerBottomNavigation');
//       } 
      
//     });
//         super.didChangeDependencies();

//   }  
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
      body: SingleChildScrollView(
      child: Stack(
        children: <Widget>[
         Column(
          children: <Widget> [
          SizedBox(height: size.height * 0.2,),
          Text('WELCOME TO ORGANIZERS', style: TextStyle(fontWeight: FontWeight.bold),),
   
          Center(
            child: Image.asset('assets/welcome.png', width: size.width * 0.8, height: size.height * 0.4,)
            ),
            Container(
              width: size.width * 0.8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal:40),
                  color: Colors.lightBlue,
                  //onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => LogInPage())),
                  onPressed: ()=> Provider.of<UserRepository>(context, listen: false).goToLogIn(),
                  child: Text('LOGIN', style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              width: size.width * 0.8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal:40),
                  color: Colors.lightBlue[200],
                  //onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ChooseStatusPage())),
                  onPressed: ()=> Provider.of<UserRepository>(context, listen: false).goToChooseStatus(),
                  child: Text('SIGNUP', style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ]
        ),
        Platform.isIOS ? 
        Container(
          width: size.width,
          height: size.height,
          child: Center(child: UpgradeAlert(child: Center(child: Text(''))))
          ): Container()
        ]
      ),
    ));
  }
}