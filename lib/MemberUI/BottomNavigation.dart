import 'package:flutter/material.dart';
import 'package:organizer/MemberUI/Calendar.dart';
import 'package:organizer/UI/Chat.dart';
import 'package:organizer/UI/Setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigation extends StatefulWidget {


  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentap = 1;

  String organization;
  SharedPreferences preferences;

  Chat chatPage;
  Calendar calendarPage;
  Setting settingPage;
  List<Widget> pages;
  Widget currentPage;

  final PageStorageBucket bucket = PageStorageBucket();

  void initState() {
    calendarPage = Calendar();
    chatPage = Chat();
    settingPage = Setting();
    pages = [chatPage, calendarPage, settingPage];
    currentPage = calendarPage;

    readLocal();
    super.initState();
  }

  void readLocal() async {
    preferences = await SharedPreferences.getInstance();
    organization = preferences.getString('organization') ?? ' ';

    setState(() {});
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: organization != null ? Text(organization): Text(''),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.blueAccent,
        ),
        body: PageStorage(
          child: currentPage,
          bucket: bucket,
        ),
        bottomNavigationBar: new BottomNavigationBar(
          currentIndex: _currentap,
          onTap: (int _index) {
            setState(() {
              _currentap = _index;
              currentPage = pages[_index];
            });
          },
          items: [
            new BottomNavigationBarItem(
                icon: new Icon(Icons.mail), title: new Text("Messages")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.home), title: new Text("Events")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.settings), title: new Text("Setting")),

          ],
        )
    );
  }
}
