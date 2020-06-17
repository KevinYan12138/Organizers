import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Organizations extends StatefulWidget {
  @override
  _OrganizationsState createState() => _OrganizationsState();
}

class _OrganizationsState extends State<Organizations> {

  SharedPreferences prefs;

  String email;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';

    setState(() {});
  } 

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Organization List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collectionGroup("users").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          final int messageCount = snapshot.data.documents.length;
          return ListView.builder(
            itemCount: messageCount,
            itemBuilder: (_, int index) {
              final DocumentSnapshot document = snapshot.data.documents[index];
              String status = document['status'].toString();
              Color color1 = status == 'member' ? Colors.lightBlue[100] : Colors.lightGreen[100];
              Color color2 = status == 'member' ? Colors.lightBlueAccent[100] : Colors.greenAccent[100];
              return document['email'] == email ? Card(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color1, color2] 
                    ),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  height: size.height * 0.1,
                  child: Center(
                    child: ListTile(
                      title: Text(document['organization'].toString()),
                      trailing: Text(document['status'].toString()),
                    ),
                  ),
                ),
              ): Container();
              
            },
          );
        },
      )
    );
  }
}
