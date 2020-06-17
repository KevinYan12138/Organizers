import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  var title = '';
  var year = '';
  var month = '';
  var day = '';
  var time = '';
  var description = '';

  var dateActive = false;
  var timeActive = false;
  var titleActive = false;
  var descriptionActive = false;

  var now = new DateTime.now();
  var nowTime = new TimeOfDay.now();
  var yearFormat = new DateFormat.y();
  var monthFormat = new DateFormat.M();
  var dayFormat = new DateFormat.d();

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

  int _currentStep = 0;

  Future<Null> _datePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != now)
      setState(() {
        year = yearFormat.format(picked);
        month = monthFormat.format(picked);
        if (int.parse(month) < 10) month = '0' + month;
        day = dayFormat.format(picked);
        if (int.parse(day) < 10) day = '0' + day;
      });
  }

  Future<Null> _timePicker(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: nowTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );
    if (picked != null && picked != now)
      setState(() {
        var hour = picked.hour.toString();
        var minute = picked.minute.toString();
        if (int.parse(minute) < 10) minute = '0' + minute;
        if (int.parse(hour) < 10) hour = '0' + hour;
        time = hour + ':' + minute;
      });
  }

  void handleUpdateData() {
    Firestore.instance.collection('events').document(organization).collection('events')
      .document(year + '-' + month + '-' + day + ' at ' + time).setData({
      'title': title,
      'year': int.parse(year),
      'month': int.parse(month),
      'day': int.parse(day),
      'time': time,
      'description': description,
      'organization': organization,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(
        builder: (ctx) => Container(
            child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                onStepContinue: () {
                  if(formKeys[_currentStep].currentState.validate()){
                    formKeys[_currentStep].currentState.save();
                  if (_currentStep >= 3) {
                    handleUpdateData();
                    Navigator.pop(ctx);
                  } else {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                  }
                },
                onStepCancel: () {
                  if (_currentStep <= 0) return;
                  setState(() {
                    _currentStep -= 1;
                  });
                },
                steps: <Step>[
                  Step(
                      title: Text('Select Date'),
                      isActive: dateActive,
                      content: Row(
                        children:<Widget>[ 
                          Expanded(
                            child: Form(
                              key: formKeys[0],
                              child: TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Icon(Icons.date_range),
                                labelText: year+'-'+month+'-'+day,
                                labelStyle: TextStyle(color: Colors.black),
                                errorStyle: TextStyle(
                                color: Theme.of(context).errorColor, 
                              ),
                              ),
                              validator: (value) {
                              if (year.isEmpty || year.length < 1) {
                                return 'Please enter date';
                              }else{
                                setState(() {
                                  dateActive = true;
                                });
                              }}
                              ),
                            ),
                          ),
                          Flexible(
                            child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            onPressed: () => _datePicker(context),
                            child: Text('Edit Date'),
                        ),
                          ),
                        ]
                      )
                      ),
                  Step(
                      title: Text('Select Time'),
                      isActive: timeActive,
                      content: Row(
                        children:<Widget>[ 
                          Expanded(
                            child: Form(
                              key: formKeys[1],
                              child: TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Icon(Icons.timer),
                                labelText: time,
                                labelStyle: TextStyle(color: Colors.black),
                                errorStyle: TextStyle(
                                color: Theme.of(context).errorColor, 
                              ),
                              ),
                              validator: (value) {
                              if (time.isEmpty || time.length < 1) {
                                return 'Please enter time';
                              }else{
                                setState(() {
                                  timeActive = true;
                                });
                              }}
                              ),
                            ),
                          ),
                          Flexible(
                            child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            onPressed: () => _timePicker(context),
                            child: Text('Edit Time'),
                        ),
                          ),
                        ]
                      )),
                  Step(
                    title: Text('Event Title'),
                    isActive: titleActive,
                    content: Form(
                      key: formKeys[2],
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          icon: Icon(Icons.title),
                          labelText: 'Title',
                        ),
                        onChanged: (value) {
                          title = value;
                        },
                        onSaved: (value)=> title = value,
                        validator: (value) {
                          if (value.isEmpty || value.length < 1) {
                            return 'Please enter title';
                          }else{
                            setState(() {
                              titleActive = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Step(
                    title: Text('Event Description'),
                    isActive: descriptionActive,
                    content: Form(
                      key: formKeys[3],
                      child: TextFormField(
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          icon: Icon(Icons.description),
                          labelText: 'Description',
                        ),
                        onChanged: (value) {
                          description = value;
                        },
                        onSaved: (value)=> description = value,
                        validator: (value) {
                          if (value.isEmpty || value.length < 1) {
                            return 'Please enter description';
                          }else{
                            setState(() {
                              descriptionActive = true;
                            });
                          }
                        },
                      ),
                    ),
                  )
                ])),
      ),
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
