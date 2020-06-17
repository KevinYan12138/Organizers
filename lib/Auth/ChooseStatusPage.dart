import 'package:flutter/material.dart';
import 'package:organizer/Auth/UserRepository.dart';
import 'package:provider/provider.dart';

class ChooseStatusPage extends StatefulWidget {
  @override
  _ChooseStatusPageState createState() => _ChooseStatusPageState();
}

class _ChooseStatusPageState extends State<ChooseStatusPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
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
          GestureDetector(
            //onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ManagerSignUpPage())),
            onTap: ()=> Provider.of<UserRepository>(context, listen: false).goToAdminSignUp(),
            child: Container(
              height: size.height * 0.3,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:10),
                    child: Image.asset('assets/manager.png', width: size.width * 0.5, ),
                  ),
                  SizedBox(width: size.width * 0.1,),
                  Container(
                    width: size.width * 0.3 ,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manager', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                        Text('Sign up now and simplify the process of managing your organization', 
                        style: TextStyle(color: Colors.grey,))
                      ],
                    )
                    )
                ],
              )
            ),
          ),
          SizedBox(height: size.height * 0.2,),
          GestureDetector(
            //onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => MemberSignUpPage())),
            onTap: ()=> Provider.of<UserRepository>(context, listen: false).goToMemberSignUp(),
            child: Container(
              height: size.height * 0.3,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:10),
                    child: Image.asset('assets/member.png', width: size.width * 0.5, ),
                  ),
                  SizedBox(width: size.width * 0.1,),
                  Container(
                    width: size.width * 0.3 ,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Member', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        Text('Find your organization, or ask your organization manager to join here', style: TextStyle(color: Colors.grey))
                      ],
                    )
                    )
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
}