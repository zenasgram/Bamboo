import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Mode',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  hintStyle: TextStyle(color: Colors.white70),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 3.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

int selector = 1; //default starting position (up straight)

Map<String, int> bendThresholdMap = {
  'Fantastic': 1,
  'Super': 2,
  'Excellent': 3,
  'Amazing': 4,
  'Great': 5,
  'Very Good': 6,
  'Good': 7,
  'Above Average': 8,
  'Average': 9,
  'Below Average': 10,
  'Can Be Improved': 11,
  'Bad': 12,
  'Poor': 13,
  'Very Poor': 14,
  'Extremely Poor': 15,
  'Dangerous': 16,
  'Very Dangerous': 17,
  'Extremely Dangerous': 18,
  'Terrible': 19,
  'Extremely Terrible': 20,
  'Life Threatening': 21,
};

String getThreshold(int flexValue) {
  if (flexValue < 100) {
    return 'Fantastic';
  } else if (flexValue < 200) {
    return 'Super';
  } else if (flexValue < 300) {
    return 'Excellent';
  } else if (flexValue < 400) {
    return 'Amazing';
  } else if (flexValue < 500) {
    return 'Great';
  } else if (flexValue < 600) {
    return 'Very Good';
  } else if (flexValue < 700) {
    return 'Good';
  } else if (flexValue < 800) {
    return 'Above Average';
  } else if (flexValue < 900) {
    return 'Average';
  } else if (flexValue < 1000) {
    return 'Below Average';
  } else if (flexValue < 1100) {
    return 'Can Be Improved';
  } else if (flexValue < 1200) {
    return 'Bad';
  } else if (flexValue < 1300) {
    return 'Poor';
  } else if (flexValue < 1400) {
    return 'Very Poor';
  } else if (flexValue < 1500) {
    return 'Extremely Poor';
  } else if (flexValue < 1600) {
    return 'Dangerous';
  } else if (flexValue < 1700) {
    return 'Very Dangerous';
  } else if (flexValue < 1800) {
    return 'Extremely Dangerous';
  } else if (flexValue < 1900) {
    return 'Terrible';
  } else if (flexValue < 2000) {
    return 'Extremely Terrible';
  } else {
    return 'Life Threatening';
  }
}

String statusBend = 'Fantastic';
String statusAdvice = 'Keep it up and stay posture fit!';

Map<String, String> adviceMap = {
  'Fantastic': 'Keep it up and stay posture fit!',
  'Super': 'Keep it up and stay posture fit!',
  'Excellent': 'Keep it up and stay posture fit!',
  'Amazing': 'Keep it up and stay posture fit!',
  'Great': 'Keep it up and stay posture fit!',
  'Very Good': 'Keep it up and stay posture fit!',
  'Good': 'Keep it up and stay posture fit!',
  'Above Average': 'Keep it up and stay posture fit!',
  'Average': 'Can be improved, don\'t give up!',
  'Below Average': 'Can be improved, don\'t give up!',
  'Can Be Improved': 'Don\'t give up!',
  'Bad': 'Can be improved, don\'t give up!',
  'Poor': 'Can be improved, don\'t give up!',
  'Very Poor': 'Can be improved, don\'t give up!',
  'Extremely Poor': 'Can be improved, don\'t give up!',
  'Dangerous': 'Can be improved, don\'t give up!',
  'Very Dangerous': 'Can be improved, don\'t give up!',
  'Extremely Dangerous': 'Can be improved, don\'t give up!',
  'Terrible': 'Can be improved, don\'t give up!',
  'Extremely Terrible': 'Can be improved, don\'t give up!',
  'Life Threatening': 'Can be improved, don\'t give up!',
};

void updateVariables(int xData, int yData, int timeThres) {
  if (xData > timeThres) {
    String statusKey = getThreshold(yData);
    selector = bendThresholdMap[statusKey];

    statusBend = statusKey;
    statusAdvice = adviceMap[statusKey];

    print('Just updated bamboo!');
  }
}
