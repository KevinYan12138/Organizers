import 'package:flutter/material.dart';
import 'package:organizer/UI/Chat.dart';
import 'package:organizer/UI/Setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ManagerEvents.dart';

class ManagerBottomNavigation extends StatefulWidget {
  
  @override
  _ManagerBottomNavigationState createState() => _ManagerBottomNavigationState();
}

class _ManagerBottomNavigationState extends State<ManagerBottomNavigation> {

  int _currentap = 1;

  String organization;
  SharedPreferences preferences;

  ManagerEvents managerEventsPage;
  Chat chatPage;
  Setting settingPage;
  List<Widget> pages;
  Widget currentPage;

  void initState() {
    managerEventsPage = ManagerEvents();
    chatPage = Chat();
    settingPage = Setting();
    pages = [chatPage, managerEventsPage, settingPage];
    currentPage = managerEventsPage;

    readLocal();
    super.initState();
  }

  void readLocal() async {
    preferences = await SharedPreferences.getInstance();
    organization = preferences.getString('organization') ?? ' ';

    setState(() {});
  } 

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: organization != null ? Text(organization): Text(''),    
        centerTitle: true,    
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
                icon: new Icon(Icons.settings), title: new Text("Setting"))
          ],
        )
    );
  }
}
