import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsView extends StatefulWidget {
  final DateTime eventDate;

  EventsView(this.eventDate);

  @override
  _EventsViewState createState() => _EventsViewState(this.eventDate);
}

class _EventsViewState extends State<EventsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences prefs;

  String organization;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    organization = prefs.getString('organization') ?? '';

    setState(() {});
  }

  DateTime eventDate;
  _EventsViewState(this.eventDate);

  Future<QuerySnapshot> _getEvents() async {
    FirebaseUser currentUser = await _auth.currentUser();

    if (currentUser != null) {
      QuerySnapshot events = await Firestore.instance.collection('events').document(organization).collection('events')
          .where('day', isEqualTo: eventDate.day)
          .where('month', isEqualTo: eventDate.month)
          .where('year', isEqualTo: eventDate.year)
          .getDocuments();

      return events;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(),
        title: new Text(getMonthName(eventDate.month) +' ' +eventDate.day.toString() +', ' +eventDate.year.toString()
        ),
      ),
      body: FutureBuilder(
          future: _getEvents(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return new LinearProgressIndicator();
              case ConnectionState.done:
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else {
                  return ListView(
                    children: snapshot.data.documents.map((document) {
                      return new ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width/4,
                              child: Text(
                                document.data['time'],
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            VerticalDivider(),
                          ],
                        ),
                        title: Text(
                          document.data['title'].toString(), maxLines: null,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          document.data['description'],
                          maxLines: null,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
            }
          }),
    );
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