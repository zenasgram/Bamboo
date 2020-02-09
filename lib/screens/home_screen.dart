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
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/cupertino.dart';

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
  List<ChartData> thresholdVisual = <ChartData>[];

  @override
  void initState() {
    super.initState();

    ChartData thresDataInitStart = ChartData(
        xValue:
            Timestamp.fromDate(DateTime.now().subtract(Duration(seconds: 60))),
        yValue: threshold);
    ChartData thresDataInitEnd =
        ChartData(xValue: Timestamp.now(), yValue: threshold);
    //ensures that threshold data always has at least 2 elements.
    thresholdVisual.add(thresDataInitStart);
    thresholdVisual.add(thresDataInitEnd);

    thresDataInitStart = null;
    thresDataInitEnd = null;

    //on start up, trigger sensor simulation
    Simulator sim = Simulator();
    Timer.periodic(Duration(seconds: 2), (timer) {
      sim.simulateSensor();
      if (pt != null) {
        sim.backFlexData(pt);
      }
    });

    //Screen Refresh Rate (Should be faster than sensor rate)
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        //automode selector
        if (autoMode == true) {
          if (newPageIndex != pageIndex) {
            _onItemTappedAuto(newPageIndex);
          }
        }

        if (warningStatus == true && alreadySet == false) {
          alreadySet = true;
          showOverlayNotification(
            (context) {
              return SafeArea(
                child: Card(
                  elevation: 10,
                  color: Colors.white,
                  margin: const EdgeInsets.only(left: 4, right: 4),
                  child: ListTile(
                    leading: SizedBox.fromSize(
                      size: const Size(40, 40),
                      child: Container(
                        height: 200.0,
                        child: Image.asset('images/logo.png'),
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 10),
                      child: Text(
                        'Bamboo Alert',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          textStyle: Theme.of(context).textTheme.display1,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 10),
                      child: Text(
                        'Check your posture. Remember, don\'t just do it. Bamboo it.',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          textStyle: Theme.of(context).textTheme.display1,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          OverlaySupportEntry.of(context).dismiss();
                          alreadySet = false;
                          warningStatus = false;
                        }),
                  ),
                ),
              );
            },
            duration: Duration(minutes: 60),
          );
//          warningStatus = false;
        }
      });
    });

    //-----------------------------------------------------------
    //MQTT Client
//    final MqttClient client =
//        MqttClient.withPort('test.mosquitto.org', '#', 1883);
//    mqttListener(client); //runs the mqtt Script
    //-----------------------------------------------------------

    getCurrentUser();
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
      }
    } catch (e) {
      print(e);
    }
  }

  //-----------------------------------------------------------
  //Mode Selector
  String modeTitle = 'Home';

  bool autoMode = false;

  void _onItemTapped(int index) {
    setState(() {
      pageIndex = index;
      modeTitle = modeDict[index];
      autoMode = false;

      if (index == 0) {
      } else if (index == 1) {
      } else if (index == 2) {
      } else if (index == 3) {}
    });
  }

  void _onItemTappedAuto(int index) {
    setState(() {
      pageIndex = index;
      modeTitle = modeDict[index];
      autoMode = true;

      if (index == 0) {
      } else if (index == 1) {
      } else if (index == 2) {
      } else if (index == 3) {}
    });
  }

  int pageIndex = 0;
  int newPageIndex = 0;

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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          height: 25,
                        ),
                        IconButton(
                            icon: Icon(FontAwesomeIcons.signOutAlt),
                            iconSize: 30,
                            onPressed: () {
                              //Implement logout functionality
                              _auth.signOut();
                              Navigator.pop(context);
                            }),
                        Row(
                          children: <Widget>[
                            Text(
                              'Auto',
                              style: GoogleFonts.montserrat(
                                textStyle: Theme.of(context).textTheme.display1,
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            CupertinoSwitch(
                              value: autoMode,
                              onChanged: (bool value) {
                                setState(() {
                                  autoMode = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  Widget widget;

                  if (snapshot.hasData) {
                    List<ChartData> chartData = <ChartData>[];
                    List<String> modeData = [];
                    Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                    map.forEach((dynamic, v) {
                      //updating threshold line on MODE change
                      if (newThres != threshold) {
                        thresholdVisual.clear();
                        ChartData newThresDataStart = ChartData(
                            xValue: Timestamp.fromDate(
                                DateTime.now().subtract(Duration(seconds: 60))),
                            yValue: newThres);
                        ChartData newThresDataEnd = ChartData(
                            xValue: Timestamp.now(), yValue: newThres);

                        thresholdVisual.add(newThresDataStart);
                        thresholdVisual.add(newThresDataEnd);

                        threshold = newThres;

                        newThresDataStart = null;
                        newThresDataEnd = null;
                      }
                      //updates the threshold line as time increases
                      ChartData thresData =
                          ChartData(xValue: Timestamp.now(), yValue: threshold);
                      thresholdVisual.removeLast();
                      thresholdVisual.add(thresData);
                      thresData = null;

                      if (chartData.length == 0) {
                        ChartData nullHandler =
                            ChartData(xValue: Timestamp.now(), yValue: 0);
                        chartData.add(nullHandler);
                        nullHandler = null;
                      }

                      ChartData dataItem = ChartData.fromMap(v);

                      if (dataItem.xValue.toDate().millisecondsSinceEpoch !=
                          trackingTime) {
                        chartData.add(
                            dataItem); //add to ChartData only when change is detected!
                      }

                      modeData.add(dataItem.mode);
                      if (modeData.last != null) {
                        newPageIndex = modeToIndexMap[modeData.last];
                      }
                      modeData.clear();
                      dataItem = null;

                      if (chartData.length > 61) {
                        chartData
                            .removeAt(0); //clip array for memory management
                      }

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
                            maximum:
                                DateTime.now().subtract(Duration(seconds: 2)),
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
                            AreaSeries<ChartData, dynamic>(
                                animationDuration: 0,
                                opacity: 0.5,
                                color: Colors.tealAccent,
                                dataSource: thresholdVisual,
                                xValueMapper: (ChartData data, _) {
                                  return data.xValue;
                                },
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
          currentIndex: pageIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

DateFormat inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

class ChartData {
  ChartData({this.xValue, this.yValue, this.mode});

  ChartData.fromMap(Map<dynamic, dynamic> dataMap)
      : xValue = Timestamp.fromDate(inputFormat.parse(dataMap['time'])),
        yValue = dataMap['value'],
        mode = dataMap['mode'];
  final Timestamp xValue;
  final int yValue;
  final String mode;
}
