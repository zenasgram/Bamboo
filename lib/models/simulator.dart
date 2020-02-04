import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:math';
import 'dart:convert';

var keepTrack;

class Simulator {
  final fireRTDataSim = FirebaseDatabase.instance.reference().child("flex");

  void writeData(int value, Timestamp time) {
    fireRTDataSim.push().set({
      "value": value,
      "time": time.toDate().toString(),
    });
  }

  void readData() {
    fireRTDataSim.once().then((DataSnapshot dataSnapshot) {
      print(dataSnapshot.value);
    });
  }

  void simulateSensor() {
    var rng = new Random();
    writeData(rng.nextInt(2100), Timestamp.now());
  }

  void backFlexData(String pt) {
    Map valueMap = json.decode(pt);
    fireRTDataSim.push().set(valueMap);
  }

  void updateStateStream() {
    var currentLast = fireRTDataSim.onValue.last;

    if (currentLast != keepTrack) {
      keepTrack = currentLast;
    }
  }
}
