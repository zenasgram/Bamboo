import 'package:cloud_firestore/cloud_firestore.dart';
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
  'Very good': 6,
  'Good': 7,
  'Above average': 8,
  'Average': 9,
  'Below average': 10,
  'Can be improved': 11,
  'Bad': 12,
  'Poor': 13,
  'Very poor': 14,
  'Extremely poor': 15,
  'Dangerous': 16,
  'Very dangerous': 17,
  'Extremely dangerous': 18,
  'Terrible': 19,
  'Extremely terrible': 20,
  'Life threatening': 21,
};

String getThreshold(int flexValue) {
  try {
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
      return 'Very good';
    } else if (flexValue < 700) {
      return 'Good';
    } else if (flexValue < 800) {
      return 'Above average';
    } else if (flexValue < 900) {
      return 'Average';
    } else if (flexValue < 1000) {
      return 'Below average';
    } else if (flexValue < 1100) {
      return 'Can be improved';
    } else if (flexValue < 1200) {
      return 'Bad';
    } else if (flexValue < 1300) {
      return 'Poor';
    } else if (flexValue < 1400) {
      return 'Very poor';
    } else if (flexValue < 1500) {
      return 'Extremely poor';
    } else if (flexValue < 1600) {
      return 'Dangerous';
    } else if (flexValue < 1700) {
      return 'Very dangerous';
    } else if (flexValue < 1800) {
      return 'Extremely dangerous';
    } else if (flexValue < 1900) {
      return 'Terrible';
    } else if (flexValue < 2000) {
      return 'Extremely terrible';
    } else {
      return 'Life threatening';
    }
  } catch (e) {
    print(e);
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
  'Very good': 'Keep it up and stay posture fit!',
  'Good': 'Keep it up and stay posture fit!',
  'Above average': 'Keep it up and stay posture fit!',
  'Average': 'Can be improved, don\'t give up!',
  'Below average': 'Can be improved, don\'t give up!',
  'Can be improved': 'Don\'t give up!',
  'Bad': 'Can be improved, don\'t give up!',
  'Poor': 'Can be improved, don\'t give up!',
  'Very poor': 'Can be improved, don\'t give up!',
  'Extremely poor': 'Can be improved, don\'t give up!',
  'Dangerous': 'Can be improved, don\'t give up!',
  'Very dangerous': 'Can be improved, don\'t give up!',
  'Extremely dangerous': 'Can be improved, don\'t give up!',
  'Terrible': 'Can be improved, don\'t give up!',
  'Extremely terrible': 'Can be improved, don\'t give up!',
  'Life threatening': 'Can be improved, don\'t give up!',
};

List<int> yDataList = [];
int threshold = 1300;
int newThres = 1300;
int sensitivity = 15;

bool warningStatus = false;
bool alreadySet = false;

int trackingTime = 0;

String statusKey;

int count = 0;

void updateVariables(int xData, int yData, int timeThres, String mode) {
  if (xData > timeThres && yData != null) {
    statusKey = getThreshold(yData);
    selector = bendThresholdMap[statusKey];

    statusBend = statusKey;
    statusAdvice = adviceMap[statusKey];
    newThres = thresholdMap[mode];

    sensitivity = sensitivityMap[mode];

    if (xData != trackingTime && yData != 0) {
      trackingTime = xData;
      yDataList.add(yData); //yDataList for thresholding
      print(yData);
      if (yData > newThres) {
        count++;
      } else {
        count = 0;
      }
      if (count == sensitivity) {
        warningStatus = true;
        count = 0;
      }
    }

    if (yDataList.length > 15) {
      yDataList.removeAt(0); //clip array for memory management
    }
  }
}

Map<String, int> thresholdMap = {
  'Home': 1300,
  'Music': 400,
  'Sports': 1000,
  'Sleep': 1500,
};

Map<String, int> sensitivityMap = {
  'Home': 9,
  'Music': 3,
  'Sports': 7,
  'Sleep': 14,
};

Map<String, int> modeToIndexMap = {
  'Home': 0,
  'Music': 1,
  'Sports': 2,
  'Sleep': 3,
};

List<String> modeDict = ['Home', 'Music', 'Sports', 'Sleep'];
