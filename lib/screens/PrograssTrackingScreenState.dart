import 'dart:io';

import 'package:do_it_yourself/database/DatabaseManager.dart';
import 'package:do_it_yourself/database/GenericSequence.dart';
import 'package:do_it_yourself/dto/SequenceData.dart';
import 'package:do_it_yourself/globals/Globals.dart';
import 'package:do_it_yourself/screens/PrograssTrackingScreen.dart';
import 'package:flutter/material.dart';

class PrograssTrackingScreenState extends State<PrograssTrackingScreen> {
  late String dropdownValue = "";
  late List<String> tabelsNames = [];
  late SequenceData sequenceData;
  late Table table = Table();

  @override
  Widget build(BuildContext context) {
    if (tabelsNames.isEmpty) {
      updateDropdownData();
    }
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("Assets/Images/Background_Image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Flex(direction: Axis.vertical, children: [
              Expanded(
                  flex: 2,
                  child: Stack(children: [
                    buildTitle(),
                    Globals.buildBackButton(
                        context, false, Alignment.bottomRight),
                    Globals.buildUserNameLoggedInButton()
                  ])),
              Expanded(
                flex: 1,
                child: buildPrograssTrackingInstructions(),
              ),
              Expanded(
                flex: 7,
                child: Column(children: [
                  buildDropdownMenu(),
                  SizedBox(height: 20),
                  table
                ]),
              )
            ])));
  }

  Future<void> updateDropdownData() async {
    tabelsNames = await DatabaseManager.getAllTableNames();
    tabelsNames.add("רצפים");
    setState(() {});
  }

  Widget buildTitle() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("Data/prograss_tracking_title.png"),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget buildPrograssTrackingInstructions() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("Data/prograss_tracking_instructions.png"),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget buildDropdownMenu() {
    if (tabelsNames.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return DropdownMenu<String>(
        initialSelection: "רצפים",
        onSelected: (String? value) async {
          if (!tabelsNames.contains(value)) {
            table = Table();
          } else if (value != "רצפים") {
            dropdownValue = value!;
            await initializeSequenceData();
            await updateTableData();
          } else {
            table = Table();
          }
          setState(() {});
        },
        dropdownMenuEntries:
            tabelsNames.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
      );
    }
  }

  Future<void> initializeSequenceData() async {
    sequenceData = await Globals.createSequenceData(
            dropdownValue) ?? //Change from dropdownValue to hebrew name
        SequenceData.emptyCon(); // Default value if null
    DatabaseManager.setSequenceData(sequenceData);
  }

  Future<void> updateTableData() async {
    List<GenericSequence> genericSequencesList =
        await DatabaseManager.getSequencesList();

    table = await Globals.buildTable(genericSequencesList, false);
  }
}
