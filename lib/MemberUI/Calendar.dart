import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

import 'EventsView.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  SharedPreferences prefs;
  
  DateTime _dateTime;
  QuerySnapshot _userEventSnapshot;
  int _beginMonthPadding = 0;
  String organization;

  _CalendarState() {
    _dateTime = DateTime.now();
    setMonthPadding();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    organization = prefs.getString('organization') ?? '';

    setState(() {});
  }

  
  @override
  void initState() {
    super.initState();
    readLocal();

    if(Platform.isAndroid || Platform.isIOS){

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("******** - onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("******** - onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("******** - onResume: $message");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      print('push token: ' + token);

      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      QuerySnapshot snapshot = await Firestore.instance.collection('users').document(organization).collection('users')
          .where('email', isEqualTo: user.email).getDocuments();

      snapshot.documents.forEach((doc) {
        Firestore.instance.collection('users').document(organization).collection('users').document(doc.documentID)
            .updateData({'token': token});
      });
    });
    }
  }
  

  void setMonthPadding() {
    _beginMonthPadding =
        new DateTime(_dateTime.year, _dateTime.month, 1).weekday;
    _beginMonthPadding == 7 ? (_beginMonthPadding = 0) : _beginMonthPadding;
  }

  Future<QuerySnapshot> _getCalendarData() async {
    FirebaseUser currentUser = await _auth.currentUser();

    if (currentUser != null) {
      QuerySnapshot userEvents = await Firestore.instance.collection('events').document(organization).collection('events')
          .where('month', isGreaterThanOrEqualTo: _dateTime.month)
          .getDocuments();

      _userEventSnapshot = userEvents;
      return _userEventSnapshot;
    } else {
      return null;
    }
  }

  void _goToToday() {
    setState(() {
      _dateTime = DateTime.now();

      setMonthPadding();
    });
  }

  void _previousMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.january)
        _dateTime = new DateTime(_dateTime.year - 1, DateTime.december);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month - 1);

      setMonthPadding();
    });
  }

  void _nextMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.december)
        _dateTime = new DateTime(_dateTime.year + 1, DateTime.january);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month + 1);

      setMonthPadding();
    });
  }

  void _onDayTapped(int day) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new EventsView(
                new DateTime(_dateTime.year, _dateTime.month, day))));
  }

  @override
  Widget build(BuildContext context) {
    final int numWeekDays = 7;
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    /*28 is for weekday labels of the row*/
    // 55 is for iPhoneX clipping issue.
    final double itemHeight = (size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight -
            24 -
            28 -
            55) /
        6 /
        1.5;
    final double itemWidth = size.width / numWeekDays;

    return new Scaffold(
        backgroundColor: Colors.white,
        body: new FutureBuilder(
            future: _getCalendarData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return new LinearProgressIndicator();
                case ConnectionState.done:
                  return new Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              color: Colors.black,
                              size: 30,
                            ),
                            onPressed: _previousMonthSelected,
                          ),
                          Spacer(
                            flex: 1,
                          ),
                          FittedBox(
                            fit: BoxFit.contain,
                            child: new Text(
                              getMonthName(_dateTime.month) +
                                  " " +
                                  _dateTime.year.toString(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: Colors.black,
                                size: 30,
                              ),
                              onPressed: _nextMonthSelected),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      new GridView.count(
                        crossAxisCount: numWeekDays,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: List.generate(7, (index) {
                          return new Container(
                              //margin: const EdgeInsets.all(2.0),
                              //padding: const EdgeInsets.all(2.0),
                              //decoration: new BoxDecoration(border: new Border.all(color: Colors.grey)),
                              child: new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  buildDayName(index)
                                ],
                              ));
                        }),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Flexible(
                        child: new GridView.count(
                          crossAxisCount: numWeekDays,
                          //childAspectRatio: (itemWidth / itemHeight),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: List.generate(
                              getNumberOfDaysInMonth(_dateTime.month),
                              (index) {
                            int dayNumber = index + 1;
                            return new GestureDetector(
                                // Used for handling tap on each day view
                                onTap: () => _onDayTapped(
                                    dayNumber - _beginMonthPadding),
                                child: new Container(
                                    //margin: const EdgeInsets.all(2.0),
                                    //padding: const EdgeInsets.all(2.0),
                                    //decoration: new BoxDecoration(border: new Border.all(color: Colors.grey)),
                                    child: new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        buildDayNumberWidget(dayNumber),
                                        buildDayEventInfoWidget(dayNumber),
                                      ],
                                    )));
                          }),
                        ),
                      )
                    ],
                  );
                  break;
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else
                    return new Text('Result: ${snapshot.data}');
              }
            }));
  }
  Text buildDayName(int index){
    return new Text(getDayName(index), style: TextStyle(fontSize: 20),textAlign: TextAlign.center,);
  }

  Text buildDayNumberWidget(int dayNumber) {
    //print('buildDayNumberWidget, dayNumber: $dayNumber');
    if ((dayNumber - _beginMonthPadding) == DateTime.now().day &&
        _dateTime.month == DateTime.now().month &&
        _dateTime.year == DateTime.now().year) {
      // Today
      return new Text(
        (dayNumber - _beginMonthPadding).toString(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.red),
      );
    } else {
      // Not Today
      return new Text(
        dayNumber <= _beginMonthPadding
            ? ' '
            : (dayNumber - _beginMonthPadding).toString(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      );
    }
  }

  Icon buildDayEventInfoWidget(int dayNumber) {
    int eventCount = 0;

    _userEventSnapshot.documents.forEach((doc) {
      int year = doc.data['year'];
      int month = doc.data['month'];
      int day = doc.data['day'];

      if (day == dayNumber - _beginMonthPadding &&
          month == _dateTime.month &&
          year == _dateTime.year) {
        eventCount++;
      }
    });

    if (eventCount > 0) {
      return Icon(
        Icons.brightness_1,
        size: MediaQuery.of(context).size.width / 90,
        color: Colors.lightBlue,
      );
    } else {
      return Icon(
        Icons.brightness_1,
        size: MediaQuery.of(context).size.width / 90,
        color: Colors.white,
      );
    }
  }

  int getNumberOfDaysInMonth(final int month) {
    int numDays = 28;

    switch (month) {
      case 1:
        numDays = 31;
        break;
      case 2:
        numDays = 28;
        break;
      case 3:
        numDays = 31;
        break;
      case 4:
        numDays = 30;
        break;
      case 5:
        numDays = 31;
        break;
      case 6:
        numDays = 30;
        break;
      case 7:
        numDays = 31;
        break;
      case 8:
        numDays = 31;
        break;
      case 9:
        numDays = 30;
        break;
      case 10:
        numDays = 31;
        break;
      case 11:
        numDays = 30;
        break;
      case 12:
        numDays = 31;
        break;
      default:
        numDays = 28;
    }
    return numDays + _beginMonthPadding;
  }

  String getDayName(final int index) {
    // Months are 1, ..., 12
    switch (index) {
      case 0:
        return "S";
      case 1:
        return "M";
      case 2:
        return "T";
      case 3:
        return "W";
      case 4:
        return "T";
      case 5:
        return "F";
      case 6:
        return "S";
      default:
        return "Unknown";
    }
  }

  String getMonthName(final int month) {
    // Months are 1, ..., 12
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "Unknown";
    }
  }
}
