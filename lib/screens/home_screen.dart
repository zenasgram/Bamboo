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
      duration: Duration(seconds: 2),
      vsync: this,
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    controller.forward();

    controller.addListener(() {
      if (animation.value == 1) {
        controller.reverse();
      } else if (animation.value == 0) {
        controller.forward();
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
              Flexible(
                child: Container(
                  alignment: Alignment(-0.15 + 0.3 * animation.value, 0),
                  child: Image.asset('images/bamboo$selector.png'),
//                  height: 300 + 10 * animation.value,
                ),
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    StreamBuilder<void>(
                      stream: fireData.orderBy('time').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        Widget widget;
                        if (snapshot.hasData) {
                          List<ChartData> chartData = <ChartData>[];
                          for (int index = 0;
                              index < snapshot.data.documents.length;
                              index++) {
                            DocumentSnapshot documentSnapshot =
                                snapshot.data.documents[index];

                            // here we are storing the data into a list which is used for chart’s data source
                            chartData
                                .add(ChartData.fromMap(documentSnapshot.data));
                          }
                          widget = Container(
                            height: 200,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SfCartesianChart(
                              primaryXAxis: DateTimeAxis(
                                intervalType: DateTimeIntervalType.hours,
                                interval: 2,
                                maximum: DateTime.now(),
                                minimum: DateTime.now()
                                    .subtract(Duration(hours: 12)),
                              ),
                              primaryYAxis: NumericAxis(
//                            maximum: 20000,
//                            minimum: 0,
                                  ),
                              series: <ChartSeries<ChartData, dynamic>>[
                                SplineAreaSeries<ChartData, dynamic>(
                                    color: Colors.tealAccent,
                                    opacity: 0.8,
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) {
                                      updateVariables(
                                          data.xValue
                                              .toDate()
                                              .millisecondsSinceEpoch,
                                          data.yValue,
                                          DateTime.now()
                                              .subtract(Duration(minutes: 5))
                                              .millisecondsSinceEpoch);
                                      return data.xValue;
                                    },
                                    yValueMapper: (ChartData data, _) =>
                                        data.yValue),
                              ],
                              margin: EdgeInsets.all(20),
                              plotAreaBorderColor: Colors.transparent,
                              tooltipBehavior: TooltipBehavior(enable: true),
                            ),
                          );
                        }
                        return widget;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
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
                                  fontSize: 17,
                                  fontWeight: FontWeight.w200,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData({this.xValue, this.yValue});
  ChartData.fromMap(Map<String, dynamic> dataMap)
      : xValue = dataMap['time'],
        yValue = dataMap['value'];
  final Timestamp xValue;
  final int yValue;
}
