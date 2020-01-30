import 'package:flutter/material.dart';
import 'package:bamboo/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:expandable_card/expandable_card.dart';
import 'package:flutter_3d_obj/flutter_3d_obj.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  List<FlexData> chartData1 = <FlexData>[
    FlexData(1, 40),
    FlexData(2, 70),
    FlexData(3, 60),
    FlexData(4, 40),
    FlexData(5, 30),
    FlexData(6, 50),
    FlexData(7, 45),
    FlexData(9, 35),
    FlexData(10, 28),
    FlexData(11, 34),
    FlexData(12, 32),
  ];

  List<FlexData> chartData2 = <FlexData>[
    FlexData(1, 10),
    FlexData(2, 30),
    FlexData(3, 20),
    FlexData(4, 50),
    FlexData(5, 70),
    FlexData(6, 30),
    FlexData(7, 35),
    FlexData(9, 25),
    FlexData(10, 40),
    FlexData(11, 10),
    FlexData(12, 15),
  ];

  @override
  void initState() {
    super.initState();

    getCurrentUser();

    controller = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
      upperBound: 1,
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    controller.forward();

    controller.addListener(() {
      if (animation.value == 1) {
        controller.reset();
        controller.forward();
      }
      setState(() {});
//      print(animation.value);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Object3D(
                      size: Size(50, 50),
                      path: 'assets/figure.obj',
                      asset: true,
                      zoom: 45,
                      angleY: animation.value * -360,
                    ),
                  ],
                ),
              ),
              Container(
                height: 250,
                child: SfCartesianChart(
                  series: <ChartSeries>[
                    SplineAreaSeries<FlexData, double>(
                        color: Colors.tealAccent,
                        opacity: 0.8,
                        dataSource: chartData1,
                        splineType: SplineType.cardinal,
                        cardinalSplineTension: 0.9,
                        xValueMapper: (FlexData sales, _) => sales.duration,
                        yValueMapper: (FlexData sales, _) => sales.flexValue),
                    SplineAreaSeries<FlexData, double>(
                        color: Colors.redAccent,
                        opacity: 0.8,
                        dataSource: chartData2,
                        splineType: SplineType.cardinal,
                        cardinalSplineTension: 0.9,
                        xValueMapper: (FlexData sales, _) => sales.duration,
                        yValueMapper: (FlexData sales, _) => sales.flexValue),
                  ],
                  margin: EdgeInsets.all(20),
                  plotAreaBorderColor: Colors.transparent,
                  crosshairBehavior: CrosshairBehavior(
                    // Enables the crosshair
                    enable: true,
                    lineColor: Colors.red,
                    lineDashArray: <double>[5, 5],
                    lineWidth: 2,
                    lineType: CrosshairLineType.vertical,
                    activationMode: ActivationMode.singleTap,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white70, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 5.0, left: 6.0, right: 6.0, bottom: 6.0),
                    child: ExpansionTile(
                      title: Text(
                        'Information',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          textStyle: Theme.of(context).textTheme.display1,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0, left: 20.0, right: 20.0, bottom: 20.0),
                          child: Text(
                            'High slouch rate detected at work, be careful.',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              textStyle: Theme.of(context).textTheme.display1,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlexData {
  FlexData(this.duration, this.flexValue);

  final double duration;
  final double flexValue;
}
