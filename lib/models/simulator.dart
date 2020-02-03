import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:math';

class Simulator {
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

  void simulateSensor() {
    var rng = new Random();
    writeData(rng.nextInt(2100), Timestamp.now());
  }
}
