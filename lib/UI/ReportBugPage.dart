import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportBugPage extends StatefulWidget {

  final String subject;

  const ReportBugPage({Key key, this.subject}) : super(key: key);

  @override
  _ReportBugPageState createState() => _ReportBugPageState();
}

class _ReportBugPageState extends State<ReportBugPage> {
  String body;
  //String email;
  String name;
  String contactInfo;
  bool isLoading = false;

  SharedPreferences preferences;

  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // @override
  // void initState() {
  //   super.initState();
  //   readLocal();
  // }

  // void readLocal() async {
  //   preferences = await SharedPreferences.getInstance();

  //   email = preferences.getString('email') ?? '';

  //   setState(() {});
  // }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  } 

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Report')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Stack(
              children: [
               Center(
                 child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    _showSubject(),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                     _showName(),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    _showBody(),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    _submit(),
                  ],
              ),
               ),
              isLoading ? Padding(
                padding: EdgeInsets.fromLTRB(size.width * 0.35, size.height * 0.7, size.width * 0.35, size.height * 0.1),
                child: Container(
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                  child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightBlue),)),
              ): Container()
              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget _showSubject() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.1,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          labelText: 'Your email address',
          labelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        validator: (value) => value.isEmpty ? 'Contact Info can\'t be empty' : null,
        onSaved: (value) {
          contactInfo = value;
        },
      ),
    );
  }
  Widget _showName() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.1,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          labelText: 'Your Name',
          labelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
        onSaved: (value) {
          name = value;
        },
      ),
    );
  }

  Widget _showBody() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.5,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        maxLines: 30,
        keyboardType: TextInputType.multiline,
        autofocus: false,
        decoration: InputDecoration(
          labelText: 'Enter Your Message Here',
          labelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        validator: (value) => value.isEmpty ? 'Message can\'t be empty' : null,
        onSaved: (value) {
          body = value;
        },
      ),
    );
  }

  Widget _submit() {
  Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      child: RaisedButton(
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(50.0),
            side: BorderSide(color: Colors.lightBlue)),
        child: Text('Send', style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Colors.white)),
        onPressed: ()async{
          if(_validateAndSave()){

           setState(() {
                isLoading = true;
              });

            String username = 'guanwenyansmtpserver@gmail.com';
            String password = 'Kevin20173188';
            final smtpServer = gmail(username, password);

            final message = Message()
              ..from = Address(contactInfo, name + ': ' + contactInfo)
              ..recipients.add('organizers@guanwenyan.com')
              ..subject = widget.subject
              ..text = body;

              try {
                await send(message, smtpServer);
              } on MailerException catch (e) {
                print('Message not sent.');
                print(e.toString());
                for (var p in e.problems) {
                  print('Problem: ${p.code}: ${p.msg}');
                }
              }
              

              setState(() {
                isLoading = false;
              });
              _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Sent Successfully. We will reply to you as soon as possible!'),));

              Future.delayed(const Duration(milliseconds: 3000), () {
                Navigator.pop(context);
              });
          }
        },
      ),
    );
  }
}
