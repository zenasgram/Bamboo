import 'package:bamboo/screens/login_screen.dart';
import 'package:bamboo/screens/registration_screen.dart';
import 'package:bamboo/components/rounded_button.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4E5ADF).withOpacity(animation.value),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: animation.value * 70,
                  ),
                ),
                TyperAnimatedTextKit(
                  text: ['Bamboo', 'Posture', 'Tracker'],
                  textStyle: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              colour: Color(0xFFFEAA47),
              title: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              colour: Color(0xFFFD586B),
              title: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
