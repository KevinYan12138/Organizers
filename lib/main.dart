import 'package:flutter/material.dart';
import 'package:organizer/Auth/CreateMoreOrganizations.dart';
import 'package:organizer/Auth/JoinMoreOrganizations.dart';
import 'package:organizer/ManagerUI/ManagerBottomNavigation.dart';
import 'package:provider/provider.dart';
import 'Auth/ChooseStatusPage.dart';
import 'Auth/LogInPage.dart';
import 'Auth/ManagerSignUpPage.dart';
import 'Auth/MemberSignUpPage.dart';
import 'Auth/UserRepository.dart';
import 'Auth/WelcomePage.dart';
import 'MemberUI/BottomNavigation.dart';
import 'Services/FirestoreRepository.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRepository()),
        ChangeNotifierProvider(create: (_) => FirestoreRepository()),
      ], 
      child: MaterialApp( 
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        home: HomePage(),
      )
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //TODO: why if statement does not work
    return ChangeNotifierProvider(
      create: (_) => UserRepository(),
      child: Consumer<UserRepository>(
        builder: (context, UserRepository user, _) {
          switch (user.status) {
            case Status.Uninitialized:
              return Splash();
            case Status.Unauthenticated:
              return  WelcomePage();
            case Status.Authenticating:
              return Splash();
            case Status.UserAuthenticated:
              return BottomNavigation();
            case Status.AdminAuthenticated:
              return ManagerBottomNavigation();
            case Status.Welcome:
              return WelcomePage();
            case Status.ChooseStatus:
              return ChooseStatusPage();
            case Status.LogIn:
              return LogInPage();
            case Status.MemberSignUP:
              return MemberSignUpPage();
            case Status.AdminSignUP:
              return ManagerSignUpPage();
            case Status.JoinMoreOrganizations:
              return JoinMoreOrganizations();
            case Status.CreateMoreOrganizations:
              return CreateMoreOrganizations();
          }
        },
      ),
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

