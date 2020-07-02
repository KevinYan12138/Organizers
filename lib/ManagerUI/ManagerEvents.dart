import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:organizer/ManagerUI/addEvent.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

class ManagerEvents extends StatefulWidget {
  @override
  _ManagerEventsState createState() => _ManagerEventsState();
}

class _ManagerEventsState extends State<ManagerEvents> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  SharedPreferences prefs;
  String organization;
  DateTime androidUpdatedTime;
  int _androidUpdatedTime;

  AppUpdateInfo _updateInfo;
  bool _flexibleUpdateAvailable = false;

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    organization = prefs.getString('organization') ?? '';
    _androidUpdatedTime = prefs.getInt('androidUpdatedTime') ?? DateTime.now().millisecondsSinceEpoch;
    androidUpdatedTime = DateTime.fromMillisecondsSinceEpoch(_androidUpdatedTime);

    if (Platform.isAndroid) {
      if (androidUpdatedTime == null ||
          androidUpdatedTime.isBefore(DateTime.now()) ||
          androidUpdatedTime.isAtSameMomentAs(DateTime.now())) checkForUpdate();
    }

    setState(() {});
  }

  RateMyApp rateMyApp = RateMyApp(
      minLaunches: 30, remindLaunches: 10, minDays: 14, remindDays: 3);

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) async {
      if (info.updateAvailable) {
        await prefs.setInt('androidUpdatedTime', DateTime.now().add(new Duration(days: 3)).millisecondsSinceEpoch);

        InAppUpdate.startFlexibleUpdate();
        InAppUpdate.completeFlexibleUpdate();
      }
    }).catchError((e) => print(e));
  }

  @override
  void initState() {
    super.initState();
    readLocal();

    rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(context,
            title: 'Enjoying Organizers?',
            message: 'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute :)');
      }
    });

    if (Platform.isAndroid || Platform.isIOS) {
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
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: false));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });

      _firebaseMessaging.getToken().then((String token) async {
        assert(token != null);
        print('push token: ' + token);

        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        QuerySnapshot snapshot = await Firestore.instance
            .collection('users')
            .document(organization)
            .collection('users')
            .where('email', isEqualTo: user.email)
            .getDocuments();

        snapshot.documents.forEach((doc) {
          Firestore.instance
              .collection('users')
              .document(organization)
              .collection('users')
              .document(doc.documentID)
              .updateData({'token': token});
        });
      });
    }
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Center(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Text(
                          document['time'],
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 4.5,
                        child: Text(
                          getMonthName(document['month']) +
                              ' ' +
                              document['day'].toString() +
                              ', ' +
                              document['year'].toString(),
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  VerticalDivider(),
                ],
              ),
              title: Text(
                document['title'],
                maxLines: null,
              ),
              subtitle: Text(document['description'], maxLines: null),
              trailing: Icon(Icons.delete),
              onTap: () {
                document.reference.delete();
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(children: [
          StreamBuilder(
              stream: Firestore.instance
                  .collection('events')
                  .document(organization)
                  .collection('events')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
                final int eventCount = snapshot.data.documents.length;
                return ListView.builder(
                  itemCount: eventCount,
                  itemBuilder: (context, index) =>
                      _buildListItem(context, snapshot.data.documents[index]),
                );
              }),
          if (Platform.isIOS)
            UpgradeAlert(
                showIgnore: false,
                child: Center(child: Container(child: Text('')))),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddEvent())),
          icon: Icon(Icons.add),
          label: Text('Add Event'),
          backgroundColor: Colors.red,
        ));
  }

  String getMonthName(int month) {
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
