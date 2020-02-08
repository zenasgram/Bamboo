import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bamboo/constants.dart';
import 'package:bamboo/models/mqtt.dart';
import 'package:bamboo/models/simulator.dart';

import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
//  AnimationController controller;
//  Animation animation;

  List<ChartData> thresholdVisual = <ChartData>[];

  @override
  void initState() {
    super.initState();

    //on start up, trigger sensor simulation
    Simulator sim = Simulator();
    Timer.periodic(Duration(seconds: 2), (timer) {
      sim.simulateSensor();
      if (pt != null) {
        sim.backFlexData(pt);
      }
    });

    //Screen Refresh Rate (Should be faster than sensor rate)
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });

    final MqttClient client =
        MqttClient.withPort('test.mosquitto.org', '#', 1883);
//    mqttListener(client); //runs the mqtt Script

    getCurrentUser();
//
//    controller = AnimationController(
//      duration: Duration(seconds: 3),
//      vsync: this,
//    );
//
//    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
//    controller.forward();
//
//    controller.addListener(() {
//      if (animation.value == 1) {
//        controller.reverse();
//      } else if (animation.value == 0) {
//        controller.forward();
//      }
//      setState(() {});
//    });
  }

  //Real-time database instance (For storing flex sensor data backup)

  final fireRTData = FirebaseDatabase.instance
      .reference()
      .child("flex")
      .orderByChild('time')
      .limitToLast(31);

  //Cloud firestore instance (For user registration)
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  final CollectionReference fireData = Firestore.instance.collection('flex');

  //listens to any change in database collection
  void flexStream() async {
    await for (var snapshot in fireData.snapshots()) {
      for (var flex in snapshot.documents) {
        print(flex.data);
      }
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
//        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  //-----------------------------------------------------------
  //Mode Selector
  String modeTitle = 'Home';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      modeTitle = modeDict[index];

      if (index == 0) {
      } else if (index == 1) {
      } else if (index == 2) {
      } else if (index == 3) {}
    });
  }

  List<String> modeDict = ['Home', 'Music', 'Sports', 'Sleep'];

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Home',
      style: optionStyle,
    ),
    Text(
      'Music',
      style: optionStyle,
    ),
    Text(
      'Sports',
      style: optionStyle,
    ),
    Text(
      'Sleep',
      style: optionStyle,
    ),
  ];

  //-----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 0.5, 0.7, 0.9],
          colors: [
            Colors.indigo[900],
            Colors.deepPurple[800],
            Colors.deepPurple[600],
            Colors.deepPurple[400],
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(top: 15.0, left: 20, right: 20, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '$modeTitle',
                          style: GoogleFonts.montserrat(
                            textStyle: Theme.of(context).textTheme.display1,
                            fontSize: 60,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        Text(
                          'mode',
                          style: GoogleFonts.montserrat(
                            textStyle: Theme.of(context).textTheme.display1,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                        icon: Icon(FontAwesomeIcons.signOutAlt),
                        iconSize: 30,
                        onPressed: () {
                          //Implement logout functionality
                          _auth.signOut();
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: Colors.grey.shade400,
                  height: 36,
                  thickness: 2,
                ),
              ),
              SizedBox(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(7),
                      alignment: Alignment.centerRight,
//                      Alignment(8.2 + 0.5 * animation.value, 0),
                      child: Image.asset('images/$modeTitle-back$selector.png'),
                      height: 170,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
//                      Alignment(-7.2 + -0.5 * animation.value, 0),
                      child:
                          Image.asset('images/$modeTitle-front$selector.png'),
                      height: 170,
                    ),
                  ],
                ),
              ),
              StreamBuilder<void>(
                stream: fireRTData.onValue,
//                      stream: fireData.orderBy('time').snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  Widget widget;

                  if (snapshot.hasData) {
                    List<ChartData> chartData = <ChartData>[];
                    Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                    map.forEach((dynamic, v) {
                      ChartData thresData = ChartData(
                          xValue: Timestamp.fromDate(DateTime.now()),
                          yValue: threshold);
                      thresholdVisual.add(thresData);

                      ChartData dataItem = ChartData.fromMap(v);
                      chartData.add(dataItem);

                      return chartData
                          .sort((a, b) => a.xValue.compareTo(b.xValue));
                    });

                    widget = Flexible(
                      child: Container(
                        padding: EdgeInsets.only(right: 20),
                        height: 400,
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.jm(),
                            intervalType: DateTimeIntervalType.minutes,
                            interval: 1,
                            maximum: DateTime.now(),
                            minimum:
                                DateTime.now().subtract(Duration(minutes: 1)),
                          ),
                          primaryYAxis: NumericAxis(
                            isVisible: true,
                            maximum: 2200,
                            minimum: 0,
                            labelFormat: ' ',
                            title: AxisTitle(
                                text: 'Slouch Level',
                                textStyle: ChartTextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 15,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w600)),
                          ),
                          series: <ChartSeries<ChartData, dynamic>>[
                            SplineAreaSeries<ChartData, dynamic>(
                                animationDuration: 0,
                                color: Colors.tealAccent,
                                gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    stops: [
                                      0.1,
                                      0.4,
                                      0.7,
                                    ],
                                    colors: [
                                      Colors.teal[200],
                                      Colors.orange[500],
                                      Colors.red[500],
                                    ]),
                                opacity: 0.8,
                                dataSource: chartData,
                                xValueMapper: (ChartData data, _) {
                                  if (data.yValue != null) {
                                    updateVariables(
                                        data.xValue
                                            .toDate()
                                            .millisecondsSinceEpoch,
                                        data.yValue,
                                        DateTime.now()
                                            .subtract(Duration(seconds: 2))
                                            .millisecondsSinceEpoch,
                                        modeTitle);
                                  }
                                  return data.xValue;
                                },
                                yValueMapper: (ChartData data, _) =>
                                    data.yValue),
                            LineSeries<ChartData, dynamic>(
                                animationDuration: 0,
                                color: Colors.tealAccent,
                                dataSource: thresholdVisual,
                                xValueMapper: (ChartData data, _) =>
                                    data.xValue,
                                yValueMapper: (ChartData data, _) =>
                                    data.yValue),
                          ],
                          margin: EdgeInsets.all(20),
                          plotAreaBorderColor: Colors.transparent,
                        ),
                      ),
                    );
                  }
                  if (widget != null) {
                    return widget;
                  }
                  return Expanded(
                    child: SizedBox(
                      height: 10,
                    ),
                  );
                },
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15, left: 15, right: 15, bottom: 20),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white70, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20,
                                        left: 20,
                                        right: 20,
                                        bottom: 0),
                                    child: Text(
                                      'Information',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .display1,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 5,
                                        left: 20.0,
                                        right: 20.0,
                                        bottom: 20.0),
                                    child: Text(
                                      '$statusBend posture! $statusAdvice',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .display1,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                child:
                                    Image.asset('images/bamboo$selector.png'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0.0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: Colors.transparent,
              icon: Icon(FontAwesomeIcons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.transparent,
              icon: Icon(FontAwesomeIcons.music),
              title: Text('Music'),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.transparent,
              icon: Icon(FontAwesomeIcons.running),
              title: Text('Sports'),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.transparent,
              icon: Icon(FontAwesomeIcons.bed),
              title: Text('Sleep'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

DateFormat inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

class ChartData {
  ChartData({this.xValue, this.yValue});

  ChartData.fromMap(Map<dynamic, dynamic> dataMap)
      : xValue = Timestamp.fromDate(inputFormat.parse(dataMap['time'])),
        yValue = dataMap['value'];
  final Timestamp xValue;
  final int yValue;
}
