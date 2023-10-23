import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GenericSequence {
  final String sequenceName;
  final String dateTime;
  final Map<String, String> actionTimes = {};
  late int amountOfActions;
  late String totalTime;

  GenericSequence(
      {required this.dateTime,
      required this.amountOfActions,
      required this.sequenceName,
      required this.totalTime});

  void addActionTime(int actionID, String timeTaken) {
    String columnName = "action_$actionID";

    actionTimes[columnName] = timeTaken;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> res = {};

    res["dateTime"] = dateTime;
    for (int i = 1; i <= amountOfActions; i++) {
      String columnName = "action_$i";

      res[columnName] = actionTimes[columnName];
    }

    res["totalTime"] = totalTime;

    return res;
  }

  @override
  String toString() {
    String newLine = "\n";
    String res = "$newLine$sequenceName{dateTime: $dateTime, ";

    for (int i = 1; i <= amountOfActions; i++) {
      res += "action_$i: ${actionTimes["action_$i"]!}, ";
    }

    res += "totalTime: $totalTime";

    return res;
  }
}
