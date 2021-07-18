import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:organizer/UI/FullPhoto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String id;
  final String url;

  const ChatScreen(this.username, this.id, this.url);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var detailedTimeFormat = new DateFormat.Hms();
  var timeFormat = new DateFormat.jm();
  var yearFormat = new DateFormat.y();
  var monthFormat = new DateFormat.M();
  var dayFormat = new DateFormat.d();

  var myId;
  var groupId;
  var imageUrl;
  final picker = ImagePicker();
  bool isLoading = false;
  String nextTime;
  File imageFile;
  String organization;

  SharedPreferences prefs;

  @override
  void initState() {
    readLocal();
    super.initState();
  }

  void readLocal() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    myId = user.uid;
    prefs = await SharedPreferences.getInstance();
    organization = prefs.getString('organization') ?? '';

    if (myId.hashCode >= widget.id.hashCode) {
      groupId = myId + widget.id;
    } else {
      groupId = widget.id + myId;
    }

    setState(() {});
  }

  Future getImage() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        isLoading = true;
        imageFile = File(pickedFile.path);
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child('chats')
        .child(organization)
        .child(groupId)
        .child(yearFormat.format(DateTime.now()).toString() +
            '-' +
            monthFormat.format(DateTime.now()).toString() +
            '-' +
            dayFormat.format(DateTime.now()).toString() +
            ' at ' +
            detailedTimeFormat.format(DateTime.now()).toString());
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        _sendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("This file is not an image")));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Timer(
        Duration(milliseconds: 1000),
        () => listScrollController
            .jumpTo(listScrollController.position.minScrollExtent));
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(
                  width: 12,
                ),
                (widget.url == 'null' || widget.url.isEmpty)
                    ? Icon(
                        Icons.account_circle,
                        size: 50,
                        color: Colors.grey,
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(widget.url),
                        radius: 20,
                      ),
                SizedBox(
                  width: 10,
                ),
                SelectableText(widget.username,
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
      body: Stack(children: [
        Column(children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('chats')
                  .document(organization)
                  .collection(organization)
                  .document(groupId)
                  .collection(groupId)
                  .orderBy('timeSnapshot', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    final int messageCount = snapshot.data.documents.length;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messageCount,
                      controller: listScrollController,
                      itemBuilder: (_, int index) {
                        final DocumentSnapshot document =
                            snapshot.data.documents[index];
                        bool isMe = document['sendFrom'] == myId ? true : false;
                        String currentTime = document['time'];
                        index + 1 < messageCount
                            ? nextTime =
                                snapshot.data.documents[index + 1]['time']
                            : nextTime = null;
                        bool timeSame = currentTime == nextTime;

                        document['sendTo'] == myId
                            ? document.reference.updateData(({'read': true}))
                            : '';
                        if (document['type'] == 0) {
                          return Column(children: [
                            Align(
                              alignment: Alignment.center,
                              child: timeSame
                                  ? SizedBox(
                                      height: 0,
                                    )
                                  : Text(document['time']),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 3, bottom: 3),
                              child: Align(
                                alignment: isMe
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.all(13.0),
                                  child: SelectableText(document['message']),
                                ),
                              ),
                            ),
                          ]);
                        } else if (document['type'] == 1) {
                          return Column(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(document['time']),
                            ),
                            Align(
                              alignment:
                                  isMe ? Alignment.topRight : Alignment.topLeft,
                              child: Container(
                                padding: isMe
                                    ? EdgeInsets.only(
                                        right: 7, top: 10, bottom: 10)
                                    : EdgeInsets.only(
                                        left: 7, top: 10, bottom: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullPhoto(
                                                url: document['message'])));
                                  },
                                  child: Container(
                                    height: size.width * 0.5,
                                    width: size.width * 0.5,
                                    child: CachedNetworkImage(
                                      imageUrl: document['message'],
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]);
                        }
                      },
                    );
                }
              },
            ),
          ),
          new Divider(height: 1),
          Container(
            height: 70.0,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.image,
                    size: 30,
                  ),
                  onPressed: () => getImage(),
                ),
                Flexible(
                  child: Container(
                    height: 40,
                    child: TextField(
                      controller: textEditingController,
                      decoration: new InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        hintText: "Enter your message...",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        )),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: new Icon(
                    Icons.send,
                    size: 30,
                    color: Colors.blue,
                  ),
                  onPressed: () => _sendMessage(textEditingController.text, 0),
                )
              ],
            ),
          ),
        ]),
        isLoading
            ? Center(
                child: Container(
                width: size.width * 0.8,
                height: size.height * 0.1,
                child: Card(
                  child: ListTile(
                    leading: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                    ),
                    title: Text('Uploading Photo...'),
                  ),
                ),
              ))
            : Container()
      ]),
    );
  }

  // type 0 => String
  void _sendMessage(String text, int type) async {
    String time =
        getMonthName(int.parse(monthFormat.format(DateTime.now()))).toString() +
            ' ' +
            dayFormat.format(DateTime.now()).toString() +
            ', ' +
            timeFormat.format(DateTime.now()).toString();

    String month = int.parse(monthFormat.format(DateTime.now())) < 10
        ? '0' + monthFormat.format(DateTime.now())
        : monthFormat.format(DateTime.now());
    String day = int.parse(dayFormat.format(DateTime.now())) < 10
        ? '0' + dayFormat.format(DateTime.now())
        : dayFormat.format(DateTime.now());

    String timeSnapshot = yearFormat.format(DateTime.now()) +
        '-' +
        month +
        '-' +
        day +
        ' at ' +
        detailedTimeFormat.format(DateTime.now());

    if (text.trim() != '') {
      textEditingController.clear();
      Firestore.instance
          .collection('chats')
          .document(organization)
          .collection(organization)
          .document(groupId)
          .collection(groupId)
          .document(timeSnapshot)
          .setData(
        {
          'sendFrom': myId,
          'sendTo': widget.id,
          'time': time,
          'hour': timeFormat.format(DateTime.now()).toString(),
          'month': getMonthName(int.parse(monthFormat.format(DateTime.now())))
              .toString(),
          'year': yearFormat.format(DateTime.now()).toString(),
          'day': int.parse(day),
          'timeSnapshot': timeSnapshot,
          'message': text,
          'type': type,
          'read': false,
        },
      );
    }
  }

  String getMonthName(final int month) {
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
