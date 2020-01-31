import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bamboo/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:expandable_card/expandable_card.dart';
import 'package:flutter_3d_obj/flutter_3d_obj.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    getCurrentUser();

    controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    controller.forward();

    controller.addListener(() {
      if (animation.value == 1) {
        controller.reverse();
      } else if (animation.value == 0) {
        controller.forward();
        simulateSensor();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  final fireRTData = FirebaseDatabase.instance.reference().child("flex");

  void writeData(int value, Timestamp time) {
    fireRTData.push().set({
      "value": value,
      "time": time.toDate().toString(),
    });
  }

  void readData() {
    fireRTData.once().then((DataSnapshot dataSnapshot) {
      print(dataSnapshot.value);
    });
  }

  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  final CollectionReference fireData = Firestore.instance.collection('flex');

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

  //listens to any change in database collection
  void flexStream() async {
    await for (var snapshot in fireData.snapshots()) {
      for (var flex in snapshot.documents) {
        print(flex.data);
      }
    }
  }

  void simulateSensor() {
    var rng = new Random();
    writeData(rng.nextInt(2100), Timestamp.now());
  }

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
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Home',
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
                padding: EdgeInsets.symmetric(horizontal: 30),
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
                      alignment: Alignment(8.2 + 0.5 * animation.value, 0),
                      child: Image.asset('images/back$selector.png'),
                      height: 200,
                    ),
                    Container(
                      alignment: Alignment(-7.2 + -0.5 * animation.value, 0),
                      child: Image.asset('images/front$selector.png'),
                      height: 200,
                    ),
                  ],
                ),
              ),
//              Expanded(
//                child: Container(
//                  alignment: Alignment.center,
//                  child: Image.asset('images/bamboo$selector.png'),
//                  height: 200,
//                ),
//              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    StreamBuilder<void>(
                      stream: fireRTData.onValue,
//                      stream: fireData.orderBy('time').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        Widget widget;
                        if (snapshot.hasData) {
                          List<ChartData> chartData = <ChartData>[];
                          Map<dynamic, dynamic> map =
                              snapshot.data.snapshot.value;

                          map.forEach((dynamic, v) =>
                              chartData.add(ChartData.fromMap(v)));

                          widget = Container(
                            height: 250,
                            padding: EdgeInsets.only(right: 30),
                            child: SfCartesianChart(
                              primaryXAxis: DateTimeAxis(
                                dateFormat: DateFormat.jm(),
                                intervalType: DateTimeIntervalType.minutes,
                                interval: 2,
                                maximum: DateTime.now(),
                                minimum: DateTime.now()
                                    .subtract(Duration(minutes: 5)),
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
                                ColumnSeries<ChartData, dynamic>(
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
                                                .subtract(Duration(seconds: 5))
                                                .millisecondsSinceEpoch);
                                      }

                                      return data.xValue;
                                    },
                                    yValueMapper: (ChartData data, _) =>
                                        data.yValue),
                              ],
                              margin: EdgeInsets.all(20),
                              plotAreaBorderColor: Colors.transparent,
                              tooltipBehavior: TooltipBehavior(
                                enable: true,
                                borderColor: Colors.tealAccent,
                                borderWidth: 1,
                                color: Colors.teal,
                                activationMode: ActivationMode.singleTap,
                              ),
                            ),
                          );
                        }
                        return widget;
                      },
                    ),
                  ],
                ),
              ),
//              Flexible(
//                child: SizedBox(
//                  height: 10,
//                ),
//              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15, left: 15, right: 15, bottom: 0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white70, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 20, right: 20, bottom: 0),
                              child: Text(
                                'Information',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  textStyle:
                                      Theme.of(context).textTheme.display1,
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
                                  textStyle:
                                      Theme.of(context).textTheme.display1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FontStyle.normal,
                                ),
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
