import 'dart:convert';

import 'package:do_it_yourself/database/DatabaseManager.dart';
import 'package:do_it_yourself/database/GenericSequence.dart';
import 'package:do_it_yourself/dto/SequenceData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Globals {
  static String basePath = "Data";
  static String jsonFileSuffix = "/Data.json";
  static String sequencesMapjsonFileSuffix = "/SequencesMap.json";
  static String titleImageFileSuffix = "/title.png";
  static String imageFileSuffix = "/image.png";
  static String audioFileSuffix = "/audio.mp3";
  static String sequenceImageSuffix = ".png";
  static String tmpPath = "";
  static String extensionDBFiles = ".db";
  static String totalTime = "משך כל הרצף";
  static String dateTime = "תאריך";
  static String currentSequenceImageUrl = "";
  static Map<String, String> hebrewEnglishTableName = {};

  static Widget getEmptyWidget() {
    return const SizedBox.shrink();
  }

  static String createPathForItem(String itemTitle) {
    String path;

    if (itemTitle.isEmpty) {
      path = basePath;
    } else {
      path = '$basePath/$itemTitle';
    }

    return path;
  }

  static String createJsonPathForItem(String itemTitle) {
    String path = createPathForItem(itemTitle);

    path = '$path$jsonFileSuffix';

    return path;
  }

  static String createTitleImagePathForItem(String itemTitle) {
    String path = createPathForItem(itemTitle);

    path = '$path$titleImageFileSuffix';

    return path;
  }

  static String createImagePathForItem(String itemTitle) {
    String path = createPathForItem(itemTitle);

    path = '$path$imageFileSuffix';

    return path;
  }

  static String createAudioPathForItem(String itemTitle) {
    String path = createPathForItem(itemTitle);

    path = '$path$audioFileSuffix';

    return path;
  }

  static Future<Map<String, dynamic>> readJson(String itemTitle) async {
    String jsonPath = createJsonPathForItem(itemTitle);
    String response = await rootBundle.loadString(jsonPath);
    Map<String, dynamic> data = await json.decode(response);

    return data;
  }

  static String createImagePathForSequenceItem(
      String itemTitle, String actionNumber) {
    String path = createPathForItem(itemTitle);

    path = '$path/$actionNumber$sequenceImageSuffix';

    return path;
  }

  static String getTimeDuration(int seconds, int minutes, int hours) {
    String timeDuration = "";

    timeDuration = createMeasurementString(timeDuration, hours);
    timeDuration = createMeasurementString(timeDuration, minutes);
    timeDuration = createMeasurementString(timeDuration, seconds);
    timeDuration = getSubString(timeDuration, hours, minutes);

    return timeDuration;
  }

  static String createMeasurementString(String timeDuration, int time) {
    if (time >= 10) {
      timeDuration = '$timeDuration$time:';
    } else if (time > 0 && time < 10) {
      timeDuration = '$timeDuration' + '0' + '$time:';
    } else {
      timeDuration = '$timeDuration' + '00:';
    }

    return timeDuration;
  }

  static String getSubString(String timeDuration, int hours, int minutes) {
    String res = "";
    timeDuration = timeDuration.substring(0, timeDuration.length - 1);

    while (timeDuration.startsWith('00:')) {
      timeDuration = timeDuration.substring(3, timeDuration.length);
    }

    res = timeDuration;

    if (hours == 0 && minutes == 0) {
      res = "00:" + timeDuration;
      //timeDuration = "00:$timeDuration";
    }

    return res;
  }

  static int convertSecondsToHours(int seconds) {
    return seconds ~/ 3600;
  }

  static int getMinutesRemainder(int seconds) {
    int remainingSeconds = seconds % 3600;

    return remainingSeconds ~/ 60;
  }

  static String getTimeDurationBySecondsOnly(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int remainingSeconds = totalSeconds % 3600;
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;

    return getTimeDuration(seconds, minutes, hours);
  }

  static Future<SequenceData?> createSequenceData(String itemTitle) async {
    try {
      Map<String, dynamic> jsonFileData = await Globals.readJson(itemTitle);
      String name = jsonFileData["Name"];
      String englishName = jsonFileData["EnglishName"];
      bool myChildrenAreSequences = jsonFileData["MyChildrenAreSequences"];
      String DBCommand = jsonFileData["DBCommand"];
      int amountOfItems = jsonFileData["AmountOfItems"];
      List<String> images = List<String>.from(jsonFileData["Images"]);
      Map<String, String> actionsTextMap = {};

      for (int i = 1; i <= images.length; i++) {
        actionsTextMap["action_$i"] = images[i - 1];
      }

      return SequenceData(
          name: name,
          englishName: englishName,
          myChildrenAreSequences: myChildrenAreSequences,
          DBCommand: DBCommand,
          amountOfItems: amountOfItems,
          images: images,
          actionsTextMap: actionsTextMap);
    } catch (err) {
      print(err);
      return null;
    }
  }

  static Future<Table> buildTable(
      List<GenericSequence> genericSequencesList, bool twoRowsNeeded) async {
    double tableSize = 130;

    if (genericSequencesList[0].amountOfActions >= 8) {
      tableSize = 80;
    } else if (genericSequencesList[0].amountOfActions >= 6) {
      tableSize = 100;
    }

    return Table(
      defaultColumnWidth:
          FixedColumnWidth(tableSize), // Adjust the width as needed
      border: TableBorder.all(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: getTableData(genericSequencesList, twoRowsNeeded),
    );
  }

  static List<TableRow> getTableData(
      List<GenericSequence> genericSequencesList, bool twoRowsNeeded) {
    List<TableRow> res = [];
    int length = genericSequencesList.length;
    int endIndex;

    if (twoRowsNeeded) {
      endIndex = length - 2;
    } else {
      endIndex = 0;
    }

    res.add(TableRow(
        decoration: BoxDecoration(color: Color.fromARGB(255, 179, 132, 157)),
        children: getColumnNames()));

    if (length == 1) {
      res.add(TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: getRowFromGenericSequence(genericSequencesList[0])));
    } else {
      for (int i = length - 1; i >= endIndex; i--) {
        res.add(TableRow(
            decoration: BoxDecoration(color: Colors.grey[300]),
            children: getRowFromGenericSequence(genericSequencesList[i])));
      }
    }

    return res;
  }

  static List<Widget> getColumnNames() {
    List<Widget> res = [];

    res.add(Container(
      padding: const EdgeInsets.all(4.0),
      child: Center(
          child: Text(Globals.totalTime,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))),
    ));

    for (int i = DatabaseManager.sequenceData.amountOfItems - 1; i >= 0; i--) {
      res.add(Container(
        padding: const EdgeInsets.all(4.0),
        //child: Text('action $i'),
        child: Center(
            child: Text(DatabaseManager.sequenceData.images[i],
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold))),
      ));
    }

    res.add(Container(
      padding: const EdgeInsets.all(4.0),
      child: Center(
          child: Text(Globals.dateTime,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))),
    ));

    return res;
  }

  static List<Widget> getRowFromGenericSequence(
      GenericSequence genericSequence) {
    String date = genericSequence.dateTime.split('T')[0];
    String year = date.split("-")[0];
    String month = date.split("-")[1];
    String day = date.split("-")[2];
    List<Widget> res = [];

    res.add(Container(
      padding: const EdgeInsets.all(4.0),
      color: Colors.grey[300],
      child: Center(
          child: Text(genericSequence.totalTime,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))),
    ));

    for (int i = genericSequence.amountOfActions; i > 0; i--) {
      res.add(Container(
        padding: const EdgeInsets.all(4.0),
        color: Colors.grey[300],
        child: Center(
            child: Text(genericSequence.actionTimes["action_$i"] ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold))),
      ));
    }

    res.add(Container(
      padding: const EdgeInsets.all(4.0),
      color: Colors.grey[300],
      child: Center(
          child: Text("$day/$month/$year",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))),
    ));

    return res;
  }

  static Widget buildUserNameLoggedInButton() {
    return Container(
        padding: EdgeInsets.only(left: 10, top: 20),
        child: Align(
            alignment: Alignment.topLeft,
            child: ElevatedButton(
                child: Row(children: [
                  Text(DatabaseManager.username.replaceAll("_", " ")),
                  SizedBox(width: 5),
                  Icon(Icons.person)
                ], mainAxisSize: MainAxisSize.min),
                style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 175, 76, 129)),
                onPressed: () {})));
  }

  static Widget buildBackButton(
      BuildContext context, bool isCancelButton, Alignment alignment) {
    IconData correctIcon;
    String correctText;
    EdgeInsets correctEdgeInsert;

    if (isCancelButton) {
      correctIcon = Icons.cancel;
      correctText = "בטל רצף";
      correctEdgeInsert = EdgeInsets.only(left: 50, right: 10, top: 25);
    } else {
      correctIcon = Icons.arrow_forward;
      correctText = "חזור";
      correctEdgeInsert = EdgeInsets.only(left: 50, bottom: 50, right: 10);
    }

    return Container(
        padding: correctEdgeInsert,
        child: Align(
            alignment: alignment,
            child: ElevatedButton(
                child: Row(children: [
                  Text(correctText),
                  SizedBox(width: 5),
                  Icon(correctIcon)
                ], mainAxisSize: MainAxisSize.min),
                style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 175, 76, 129)),
                onPressed: () {
                  Navigator.pop(context);
                })));
  }

  static void addPairToHebrewEnglishTableName(String key, String value) {
    hebrewEnglishTableName[key] = value;
  }

  static BoxDecoration updateBackground() {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("Assets/Images/Background_Image.jpg"),
        fit: BoxFit.cover,
      ),
    );
  }
}
