import 'dart:async';
import 'dart:io';
import 'package:do_it_yourself/database/GenericSequence.dart';
import 'package:do_it_yourself/dto/SequenceData.dart';
import 'package:do_it_yourself/globals/Globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class DatabaseManager {
  static late Future<Database> database;
  static late String totalTime;
  static late SequenceData sequenceData;
  static List<String> actionsTimesStringList = [];
  static String username = "";
  static bool isOpenedDBFile = false;

  static Future<void> runDB(List<int> actionsTimesList, int totalSeconds,
      SequenceData sequenceDataInput) async {
    sequenceData = sequenceDataInput;
    convert(actionsTimesList, totalSeconds);
    //await connectUserDatabaseFile();

    GenericSequence genericSequence = GenericSequence(
        dateTime: DateTime.now().toIso8601String(),
        amountOfActions: sequenceData.amountOfItems,
        sequenceName: sequenceData.englishName,
        totalTime: totalTime);

    for (int i = 0; i < sequenceData.amountOfItems; i++) {
      genericSequence.addActionTime(i + 1, actionsTimesStringList[i]);
    }

    await insertSequence(genericSequence);
    printItems();
  }

  static Future<List<Map<String, dynamic>>> getAllRows(String tableName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return maps;
  }

  static void convert(List<int> actionsTimesList, int totalSeconds) {
    actionsTimesStringList.clear();

    for (int i = 0; i < actionsTimesList.length; i++) {
      int item = actionsTimesList[i];
      String actionTime;

      actionTime = Globals.getTimeDurationBySecondsOnly(item);

      actionsTimesStringList.add(actionTime);
    }

    totalTime = Globals.getTimeDurationBySecondsOnly(totalSeconds);
  }

  static Future<void> connectUserDatabaseFile() async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
    }
    databaseFactoryOrNull = databaseFactoryFfi;
    database = openDatabase(
      join(
          Globals.tmpPath, DatabaseManager.username + Globals.extensionDBFiles),
      version: 1,
    );
    isOpenedDBFile = true;
  }

  static Future<void> closeDBFile() async {
    if (isOpenedDBFile) {
      Database db = await database;

      await db.close();
      isOpenedDBFile = false;
    }
  }

  static Future<void> insertSequence(GenericSequence genericSequence) async {
    final Database db = await database;

    await db.execute(sequenceData.DBCommand);
    // Command to print all of the rows in brush_teeth:
    // (await db.rawQuery('SELECT * FROM toilet_boy')).toList().forEach((row) {
    //   print("check - $row");
    // });
    await db.insert(
      sequenceData.englishName,
      genericSequence.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<GenericSequence>> getSequencesList() async {
    final List<Map<String, dynamic>> maps =
        await getAllRows(sequenceData.englishName);

    return List.generate(maps.length, (i) {
      GenericSequence genericSequence = GenericSequence(
          dateTime: maps[i]['dateTime'],
          totalTime: maps[i]['totalTime'],
          amountOfActions: sequenceData.amountOfItems,
          sequenceName: sequenceData.englishName);

      for (int j = 1; j <= sequenceData.amountOfItems; j++) {
        String columnName = "action_$j";

        genericSequence.addActionTime(j, maps[i][columnName]);
      }

      return genericSequence;
    });
  }

  static void printItems() async {
    print(await getSequencesList());
  }

  static Future<List<String>> getAllTableNames() async {
    final Database db = await database;
    final List<Map<String, Object?>> result =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
    final List<String> englishTableNames =
        result.map((row) => row['name'].toString()).toList();
    List<String> hebrewTableNames = [];

    for (int i = 0; i < englishTableNames.length; i++) {
      String item = englishTableNames[i];

      hebrewTableNames.add(Globals.hebrewEnglishTableName[item]!);
    }

    return hebrewTableNames;
  }

  static void setSequenceData(SequenceData sequenceDataInput) {
    sequenceData = sequenceDataInput;
  }
}
