import 'package:flutter/material.dart';
import 'package:bamboo/screens/welcome_screen.dart';
import 'package:bamboo/screens/login_screen.dart';
import 'package:bamboo/screens/registration_screen.dart';
import 'package:bamboo/screens/home_screen.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';

void main() {
  SyncfusionLicense.registerLicense(null);
  return runApp(Bamboo());
}

class Bamboo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF4E5ADF),
        accentColor: Color(0xFF36DEEC),
        scaffoldBackgroundColor: Color(0xFF5A64E3),
        textTheme: TextTheme(
          body1: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
      },
    );
  }
}
