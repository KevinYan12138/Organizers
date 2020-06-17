import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:organizer/Auth/ResetPasswordPage.dart';
import 'package:organizer/Auth/UserRepository.dart';
import 'package:organizer/Auth/changeUsername.dart';
import 'package:organizer/Services/FirestoreRepository.dart';
import 'package:organizer/UI/Organizations.dart';
import 'package:organizer/UI/ReportBugPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context, listen: false);
    return Scaffold(
      body: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SharedPreferences prefs;

  String id;
  String email;
  String username;
  String photoUrl;
  String organization;
  File avatarImageFile;
  final picker = ImagePicker();
  bool isImageLoading = false;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    id = user.uid;
    username = prefs.getString('username') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';
    email = prefs.getString('email') ?? '';
    organization = prefs.getString('organization') ?? '';

    setState(() {});
  }

  Future getImage() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        avatarImageFile = File(pickedFile.path);
        isImageLoading = true;
      });
          uploadFile();
    }
  }

  Future uploadFile() async {
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(organization)
        .child(email);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(organization)
              .collection('users')
              .document(email)
              .updateData({'photoUrl': photoUrl}).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isImageLoading = false;
            });
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text("Upload success")));
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context, listen: false);
    final firestore = Provider.of<FirestoreRepository>(context);
    firestore.chnageUsername();
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        (photoUrl == null || photoUrl.isEmpty)
            ? Align(
                alignment: Alignment.center,
                child: GestureDetector(
                    onTap: () => getImage(),
                    child: Container(
                      height: size.width * 0.24,
                      width: size.width * 0.24,
                      child: Stack(children: [
                        isImageLoading
                            ? Container()
                            : Icon(
                                Icons.account_circle,
                                size: size.width * 0.27,
                                color: Colors.grey,
                              ),
                        isImageLoading
                            ? Container()
                            : Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.lightBlue),
                                    child: Icon(
                                      Icons.add,
                                      size: size.width * 0.06,
                                      color: Colors.black,
                                    ))),
                        isImageLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlue),
                              ))
                            : Container()
                      ]),
                    )),
              ):
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                    onTap: () => getImage(),
                    child: Container(
                      height: size.width * 0.24,
                      width: size.width * 0.24,
                      child: Stack(children: [
                        isImageLoading
                            ? Container()
                            : CachedNetworkImage(
                                imageUrl: photoUrl,
                                imageBuilder: (context, imageProvider) => Center(
                                  child: Container(
                                    width: size.width * 0.24,
                                    height: size.width * 0.24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider, fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.account_circle,
                                  size: 60,
                                ),
                              ),
                        isImageLoading
                            ? Container()
                            : Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.lightBlue),
                                    child: Icon(
                                      Icons.add,
                                      size: size.width * 0.06,
                                      color: Colors.black,
                                    ))),
                        isImageLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlue),
                              ))
                            : Container()
                      ]),
                    )),
              ),
              // Align(
              //   alignment: Alignment.center,
              //   child: GestureDetector(
              //     onTap: () => getImage(),
              //     child: CachedNetworkImage(
              //       imageUrl: photoUrl,
              //       imageBuilder: (context, imageProvider) => Center(
              //         child: Stack(
              //           children: [
              //             Container(
              //             width: 100,
              //             height: 100,
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               image: DecorationImage(
              //                   image: imageProvider, fit: BoxFit.fill),
              //               ),
              //             ),
              //           ]
              //         ),
              //       ),
              //       placeholder: (context, url) => CircularProgressIndicator(),
              //       errorWidget: (context, url, error) => Icon(
              //         Icons.account_circle,
              //         size: 60,
              //       ),
              //     ),
              //   ),
              // ),
        SizedBox(
          height: 10,
        ),
        username != null
            ? Text(firestore.username,
                style: TextStyle(color: Colors.black, fontSize: 16))
            : Text(''),
        SizedBox(
          height: 10,
        ),
        username != null
            ? Text(email, style: TextStyle(color: Colors.grey, fontSize: 13))
            : Text(''),
        SizedBox(
          height: 20,
        ),
        menuItem(
            Icon(
              Icons.portrait,
              size: size.height * 0.04,
            ),
            'Change Username',
            ChangeUsername()),
        SizedBox(
          height: 10,
        ),
        menuItem(
            Icon(
              Icons.lock,
              size: size.height * 0.04,
            ),
            'Change Password',
            ResetPasswordPage()),
        SizedBox(height: 10),
        menuItem(
            Icon(
              Icons.bug_report,
              size: size.height * 0.04,
            ),
            'Report Bug',
            ReportBugPage(
              subject: 'Report Bug',
            )),
        SizedBox(height: 10),
        menuItem(
            Icon(
              Icons.add_comment,
              size: size.height * 0.04,
            ),
            'Request Features',
            ReportBugPage(
              subject: 'Request Features',
            )),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () => user.goToJoin(),
          child: Container(
            height: size.height * 0.07,
            width: size.width * 0.8,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).backgroundColor),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(
              Icons.group_add,
              size: size.height * 0.04,
            ),
                SizedBox(
                  width: size.width * 0.05,
                ),
                Text('Join Another Organization'),
                //SizedBox(width: size.width * 0.15,),
                //Icon(Icons.keyboard_arrow_right)
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () => user.gotoCreate(),
          child: Container(
            height: size.height * 0.07,
            width: size.width * 0.8,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).backgroundColor),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(
              Icons.playlist_add,
              size: size.height * 0.04,
            ),
                SizedBox(
                  width: size.width * 0.05,
                ),
                Text('Create Another Organization'),
                //SizedBox(width: size.width * 0.15,),
                //Icon(Icons.keyboard_arrow_right)
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        menuItem(
            Icon(
              Icons.list,
              size: size.height * 0.04,
            ),
            'Organizations Linked to You',
            Organizations()),
        SizedBox(height: 40),
        GestureDetector(
          onTap: () => user.signOut(),
          child: Container(
            height: size.height * 0.07,
            width: size.width * 0.8,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.lightBlue),
            child: Row(
              children: [
                Spacer(),
                Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget menuItem(Icon frontIcon, String text, final page) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          )),
      child: Container(
        height: size.height * 0.07,
        width: size.width * 0.8,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).backgroundColor),
        child: Row(
          children: [
            SizedBox(width: 10),
            frontIcon,
            SizedBox(
              width: size.width * 0.05,
            ),
            Text(text),
            //SizedBox(width: size.width * 0.15,),
            //Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }
}
